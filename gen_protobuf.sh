#!/bin/bash
generated_outputs="./moteur_jeu ./serveur_http ./serveur_tcp"
for path in $generated_outputs; do
    python -m grpc_tools.protoc -I./moteur_jeu/protos --python_out=$path --pyi_out=$path --grpc_python_out=$path ./moteur_jeu/protos/server.proto
done