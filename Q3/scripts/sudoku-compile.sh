#!/bin/bash

cd projects/zkPuzzles/circuits

mkdir sudokuModified

if [ -f ./powersOfTau28_hez_final_10.ptau ]; then
    echo "powersOfTau28_hez_final_10.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_10.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_10.ptau
fi

echo "Compiling sudokuModified.circom..."

# compile circuit

circom sudokuModified.circom --r1cs --wasm --sym -o sudokuModified
snarkjs r1cs info sudokuModified/sudokuModified.r1cs

# Start a new zkey and make a contribution

snarkjs groth16 setup sudokuModified/sudokuModified.r1cs powersOfTau28_hez_final_10.ptau sudokuModified/circuit_0000.zkey
snarkjs zkey contribute sudokuModified/circuit_0000.zkey sudokuModified/circuit_final.zkey --name="1st Contributor Name" -v -e="random text"
snarkjs zkey export verificationkey sudokuModified/circuit_final.zkey sudokuModified/verification_key.json

# generate solidity contract
snarkjs zkey export solidityverifier sudokuModified/circuit_final.zkey ../sudokuModifiedVerifier.sol

cd ../..