#!/bin/bash

cd contracts/circuits

mkdir Multiplier3_plonk

echo "Compiling Multiplier3.circom using PLONK"

# compile circuit

circom Multiplier3.circom --r1cs --wasm --sym -o Multiplier3_plonk
snarkjs r1cs info Multiplier3_plonk/Multiplier3.r1cs

# Generating witness
node Multiplier3_plonk/Multiplier3_js/generate_witness.js Multiplier3_plonk/Multiplier3_js/Multiplier3.wasm input.json Multiplier3_plonk/Multiplier3_js/witness.wtns

# Creating Rank 1 Constraint System JSON 
snarkjs r1cs export json  Multiplier3_plonk/Multiplier3.r1cs  Multiplier3_plonk/Multiplier3.r1cs.json
head Multiplier3_plonk/Multiplier3.r1cs.json

# Initiliazing Plonk setup
snarkjs plonk setup Multiplier3_plonk/Multiplier3.r1cs powersOfTau28_hez_final_10.ptau Multiplier3_plonk/circuit_final.zkey

# Creating Verification Key
snarkjs zkey export verificationkey Multiplier3_plonk/circuit_final.zkey Multiplier3_plonk/verification_key.json
head Multiplier3_plonk/verification_key.json

# Creating Proof
snarkjs plonk prove Multiplier3_plonk/circuit_final.zkey Multiplier3_plonk/Multiplier3_js/witness.wtns Multiplier3_plonk/proof.json Multiplier3_plonk/public.json
head Multiplier3_plonk/proof.json
head Multiplier3_plonk/public.json

# Verifying Proof
snarkjs plonk verify Multiplier3_plonk/verification_key.json Multiplier3_plonk/public.json Multiplier3_plonk/proof.json

#generate solidity contract
snarkjs zkey export solidityverifier Multiplier3_plonk/circuit_final.zkey ../Multiplier3Verifier_plonk.sol

#exporting the calldata
snarkjs zkey export soliditycalldata Multiplier3_plonk/public.json  Multiplier3_plonk/proof.json > Multiplier3_plonk/call.txt

cd ../..