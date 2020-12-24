// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

namespace Quantum.Kata.GroversAlgorithm {

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;

    //////////////////////////////////////////////////////////////////
    // Welcome!
    //////////////////////////////////////////////////////////////////
    
    // ADD STUFF HERE

    // Each task is wrapped in one operation preceded by the description of the task.
    // Each task (except tasks in which you have to write a test) has a unit test associated with it,
    // which initially fails. Your goal is to fill in the blank (marked with // ... comment)
    // with some Q# code to make the failing test pass.

    // Within each section, tasks are given in approximate order of increasing difficulty;
    // harder ones are marked with asterisks.


    //////////////////////////////////////////////////////////////////
    // Part I. Colors representation and manipulation
    //////////////////////////////////////////////////////////////////

    // Task 1.1. Initialize register to a color
    // Inputs:
    //      1) An integer C (0 ≤ C ≤ 2ᴺ - 1).
    //      2) An array of N qubits in the |0...0⟩ state.
    // Goal: Prepare the array in the basis state which represents the binary notation of C.
    //       Use little-endian encoding (i.e., the least significant bit should be stored in the first qubit).
    // Example: for N = 2 and C = 2 the state should be |01⟩.
    operation InitializeColor (C : Int, register : Qubit[]) : Unit is Adj {
        let N = Length(register);
        // Convert C to an array of bits in little endian format
        let binaryC = IntAsBoolArray(C, N);
        // Value "true" corresponds to bit 1 and requires applying an X gate
        ApplyPauliFromBitString(PauliX, true, binaryC, register);
    }


    // Task 1.2. Read color from a register
    // Input: An array of N qubits which are guaranteed to be in one of the 2ᴺ basis states.
    // Output: An N-bit integer that represents this basis state, in little-endian encoding.
    //         The operation should not change the state of the qubits.
    // Example: for N = 2 and the qubits in the state |01⟩ return 2 (and keep the qubits in |01⟩).
    operation MeasureColor (register : Qubit[]) : Int {
        return ResultArrayAsInt(MultiM(register));
    }

    
    // Task 1.3. Read coloring from a register
    // Inputs: 
    //      1) The number of elements in the coloring K.
    //      2) An array of K * N qubits which are guaranteed to be in one of the 2ᴷᴺ basis states.
    // Output: An array of K N-bit integers that represent this basis state. 
    //         Integer i of the array is stored in qubits i * N, i * N + 1, ..., i * N + N - 1 in little-endian format.
    //         The operation should not change the state of the qubits.
    // Example: for N = 2, K = 2 and the qubits in the state |0110⟩ return [2, 1].
    operation MeasureColoring (K : Int, register : Qubit[]) : Int[] {
        let N = Length(register) / K;
        let colorPartitions = Chunks(N, register);
        let coloring = ForEach(MeasureColor, colorPartitions);
        return coloring;
    }

    // Task 1.6. Two-bit adder
    // Inputs:
    //      1) two-qubit register "a" in an arbitrary state |φ⟩,
    //      2) two-qubit register "b" in an arbitrary state |ψ⟩,
    //      3) two-qubit register "sum" in state |00⟩,
    //      4) qubit "carry" in state |0⟩.
    // Goals:
    //      1) transform the "sum" register into the binary sum of φ and ψ,
    //      2) transform the "carry" qubit into the carry bit produced by that sum.
    // Note: All qubit registers in this kata are in little-endian order.
    //       This means the least significant bit comes first, then the next least significant, and so on.
    //       In this exercise, for example, 1 would be represented as |10⟩, while 2 would be represented as |01⟩.
    //       The sum of |10⟩ and |11⟩ would be |001⟩, with the last qubit being the carry qubit.
    operation TwoBitAdder (a : Qubit[], b : Qubit[], sum : Qubit[], carry : Qubit) : Unit is Adj {
        using (internalCarry = Qubit()) {
            // Set up the carry bits
            CNOT(a[0], sum[0]);
            CNOT(b[0], sum[0]);

            CCNOT(a[0], b[0], internalCarry);


            CNOT(a[1], sum[1]);
            CNOT(b[1], sum[1]);
            CNOT(internalCarry, sum[1]);

            CCNOT(a[1], b[1], carry);
            CCNOT(a[1], internalCarry, carry);
            CCNOT(b[1], internalCarry, carry);
              
            // clean up the ancilla
            Adjoint CCNOT(a[0], b[0], internalCarry);
        }

    }

}