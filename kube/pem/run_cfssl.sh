#!/bin/bash
./cfssl gencert -initca ca-csr.json | ./cfssljson -bare ca
openssl x509 -in ca.pem -text -noout

./cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kubernetes-csr.json | ./cfssljson -bare kubernetes

openssl x509 -in kubernetes.pem -text -noout
