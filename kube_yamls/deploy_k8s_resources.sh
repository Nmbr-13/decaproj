#!/bin/bash
kubectl apply -f aws_nginx_ingress_controller.yaml && kubectl apply -f deployment.yml && kubectl apply -f ingress.yaml
