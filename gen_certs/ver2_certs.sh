cert_dir="./radiant_certs"
rm -rf ${cert_dir}

mkdir -p ${cert_dir}
# Root CA
openssl genrsa -out ${cert_dir}/root-ca-key.pem 2048
openssl req -config server.cnf -new -x509 -sha256 -key ${cert_dir}/root-ca-key.pem -out ${cert_dir}/root-ca.pem
# Admin cert

echo "FINISHED ROOT CA"
openssl genrsa -out ${cert_dir}/admin-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in ${cert_dir}/admin-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out ${cert_dir}/admin-key.pem
openssl req -config server.cnf -new -key ${cert_dir}/admin-key.pem -out ${cert_dir}/admin.csr
openssl x509 -req -in ${cert_dir}/admin.csr -CA ${cert_dir}/root-ca.pem -CAkey ${cert_dir}/root-ca-key.pem -CAcreateserial -sha256 -out ${cert_dir}/admin.pem
# Node cert
echo "FINISHED ADMIN"
openssl genrsa -out ${cert_dir}/node-key-temp.pem 2048
openssl pkcs8 -inform PEM -outform PEM -in ${cert_dir}/node-key-temp.pem -topk8 -nocrypt -v1 PBE-SHA1-3DES -out ${cert_dir}/node-key.pem
openssl req -config server.cnf -new -key ${cert_dir}/node-key.pem -out ${cert_dir}/node.csr
openssl x509 -req -in ${cert_dir}/node.csr -CA ${cert_dir}/root-ca.pem -CAkey ${cert_dir}/root-ca-key.pem -CAcreateserial -sha256 -out ${cert_dir}/node.pem
# Cleanup
rm ${cert_dir}/admin-key-temp.pem
rm ${cert_dir}/admin.csr
rm ${cert_dir}/node-key-temp.pem
rm ${cert_dir}/node.csr

echo "Distinguished Name"
openssl x509 -subject -nameopt RFC2253 -noout -in ${cert_dir}/node.pem


echo "Verify certs NODE"
openssl verify -verbose -CAfile ${cert_dir}/root-ca.pem ${cert_dir}/node.pem
echo ""

echo "Verify certs CLIENT"
openssl verify -verbose -CAfile ${cert_dir}/root-ca.pem ${cert_dir}/node.pem
echo ""