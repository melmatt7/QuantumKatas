// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

//////////////////////////////////////////////////////////////////////
// This file contains reference solutions to all tasks.
// The tasks themselves can be found in Tasks.qs file.
// We recommend that you try to solve the tasks yourself first,
// but feel free to look up the solution if you get stuck.
//////////////////////////////////////////////////////////////////////

namespace Quantum.Kata.GroversAlgorithm {
    
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Quantum.Kata.Utils;

    // operation ColorEqualityOracle_Nbit (c0 : Qubit[], c1 : Qubit[], target : Qubit) : Unit is Adj+Ctl {
    //     within {
    //         // Compute bitwise XOR of c0 and c1 in place (storing it in c1)
    //         for (i in 0 .. Length(c0) - 1) {
    //             CNOT(c0[i], c1[i]);
    //         }
    //     } apply {
    //         // If all XORs are 0, c0 = c1, and our function is 1
    //         (ControlledOnInt(0, X))(c1, target);
    //     }
    // }

    // Task 1.1. Initialize register to a color
    operation InitializeColor_Reference (C : Int, register : Qubit[]) : Unit is Adj {
        let N = Length(register);
        // Convert C to an array of bits in little endian format
        let binaryC = IntAsBoolArray(C, N);
        // Value "true" corresponds to bit 1 and requires applying an X gate
        ApplyPauliFromBitString(PauliX, true, binaryC, register);
    }


    // Task 1.2. Read color from a register
    operation MeasureColor_Reference (register : Qubit[]) : Int {
        return ResultArrayAsInt(MultiM(register));
    }

    // Task 1.3. Read color from a register
    operation MeasureColoring_Reference (K : Int, register : Qubit[]) : Int[] {
        let N = Length(register) / K;
        let colorPartitions = Chunks(N, register);
        let coloring = ForEach(MeasureColor, colorPartitions);
        return coloring;
    }

    // Task 1.4. TwoBitAdder
    operation TwoBitAdder_Reference (a : Qubit[], b : Qubit[], sum : Qubit[], carry : Qubit) : Unit is Adj {
        using (internalCarry = Qubit()) {
            // Add low bits
            CNOT(a[0], sum[0]);
            CNOT(b[0], sum[0]);
            // Assign carry for low bits
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


    operation Base4Adder () : Unit is Adj {
    
    
    }



}