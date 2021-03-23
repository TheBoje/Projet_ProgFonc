#!/bin/bash
echo "Compilation started."
ocamlc expression_scanner.cmo ast.ml -o ast
echo "Compilation done."