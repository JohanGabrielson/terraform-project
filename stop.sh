#!/bin/bash
# stop.sh - Destroy CloudCorp infrastructure

echo "=== Destroying infrastructure ==="
terraform destroy -auto-approve

echo "=== Done! All resources removed ==="
