#!/bin/bash
generated_outputs="./moteur_jeu ./serveur_http ./serveur_tcp"
for path in $generated_outputs; do
    python -m grpc_tools.protoc -I./moteur_jeu/protos --python_out=$path/generated --pyi_out=$path/generated --grpc_python_out=$path/generated ./moteur_jeu/protos/server.proto
done