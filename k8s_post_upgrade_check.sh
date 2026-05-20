#!/bin/bash

# ==========================================
# Kubernetes Post-Upgrade Dependency Check
# ==========================================

OUTPUT_FILE="k8s_upgrade_check_$(date +%F_%H-%M-%S).log"

echo "==========================================" | tee -a $OUTPUT_FILE
echo " Kubernetes Post Upgrade Validation"
echo " Generated on: $(date)"
echo "==========================================" | tee -a $OUTPUT_FILE

run_check () {
    echo -e "\n==========================================" | tee -a $OUTPUT_FILE
    echo "CHECK: $1" | tee -a $OUTPUT_FILE
    echo "COMMAND: $2" | tee -a $OUTPUT_FILE
    echo "------------------------------------------" | tee -a $OUTPUT_FILE

    eval "$2" >> $OUTPUT_FILE 2>&1

    if [ $? -eq 0 ]; then
        echo "STATUS: SUCCESS" | tee -a $OUTPUT_FILE
    else
        echo "STATUS: FAILED" | tee -a $OUTPUT_FILE
    fi
}

# ==========================================
# Cluster Information
# ==========================================

run_check "Kubernetes Version" "kubectl version --short"

# ==========================================
# Node Health
# ==========================================

run_check "Node Status" "kubectl get nodes -o wide"

# ==========================================
# System Pods
# ==========================================

run_check "System Pods" "kubectl get pods -n kube-system"

# ==========================================
# All Namespace Pods
# ==========================================

run_check "All Pods Status" "kubectl get pods -A"

# ==========================================
# Failed Pods
# ==========================================

run_check "Failed Pods" \
"kubectl get pods -A | egrep 'CrashLoopBackOff|Error|Pending|Evicted'"

# ==========================================
# Events
# ==========================================

run_check "Recent Cluster Events" \
"kubectl get events -A --sort-by=.metadata.creationTimestamp | tail -50"

# ==========================================
# Ingress Controller
# ==========================================

run_check "Ingress Controller" \
"kubectl get pods -A | grep ingress"

# ==========================================
# CoreDNS
# ==========================================

run_check "CoreDNS Status" \
"kubectl get pods -n kube-system -l k8s-app=kube-dns"

# ==========================================
# Metrics Server
# ==========================================

run_check "Metrics Server" "kubectl top nodes"

# ==========================================
# Storage Classes
# ==========================================

run_check "Storage Classes" "kubectl get sc"

# ==========================================
# Persistent Volumes
# ==========================================

run_check "Persistent Volumes" "kubectl get pv"

# ==========================================
# CSI Drivers
# ==========================================

run_check "CSI Drivers" "kubectl get csidrivers"

# ==========================================
# CRDs
# ==========================================

run_check "CRDs" "kubectl get crds"

# ==========================================
# Helm Releases
# ==========================================

if command -v helm >/dev/null 2>&1; then
    run_check "Helm Releases" "helm list -A"
else
    echo "Helm not installed - skipping Helm checks" | tee -a $OUTPUT_FILE
fi

# ==========================================
# Deprecated APIs Check (Pluto)
# ==========================================

if command -v pluto >/dev/null 2>&1; then
    run_check "Deprecated APIs (Pluto)" "pluto detect-all-in-cluster"
else
    echo "Pluto not installed - skipping deprecated API check" | tee -a $OUTPUT_FILE
fi

# ==========================================
# Kubent Check
# ==========================================

if command -v kubent >/dev/null 2>&1; then
    run_check "Deprecated APIs (Kubent)" "kubent"
else
    echo "Kubent not installed - skipping kubent check" | tee -a $OUTPUT_FILE
fi

# ==========================================
# Final Summary
# ==========================================

echo -e "\n==========================================" | tee -a $OUTPUT_FILE
echo " Validation Completed"
echo " Log File: $OUTPUT_FILE"
echo "==========================================" | tee -a $OUTPUT_FILE
