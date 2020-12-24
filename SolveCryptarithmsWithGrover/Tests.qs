// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

//////////////////////////////////////////////////////////////////////
// This file contains testing harness for all tasks.
// You should not modify anything in this file.
// The tasks themselves can be found in Tasks.qs file.
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
    
    function Adder (max : Int, a : Int, b : Int) : (Int, Bool) {
        let sum = a + b;
        return (sum % max, sum >= max);
    }

    function BinaryAdder (input : Bool[], N : Int) : Bool[] {
        let max = 1 <<< N;
        let bitsa = input[0 .. N-1];
        let bitsb = input[N ...];
        let a = BoolArrayAsInt(bitsa);
        let b = BoolArrayAsInt(bitsb);
        let (sum, carry) = Adder(max, a, b);
        return IntAsBoolArray(sum, N) + [carry];
    }

    //////////////////////////////////////////////////////////////////
    // Part I. Colors representation and manipulation
    //////////////////////////////////////////////////////////////////

    operation T11_InitializeColor_Test () : Unit {
        for (N in 1 .. 4) {
            using (register = Qubit[N]) {
                for (C in 0 .. (1 <<< N) - 1) {
                    InitializeColor(C, register);
                    let measurementResults = MultiM(register);
                    Fact(ResultArrayAsInt(measurementResults) == C, 
                        $"Unexpected initialization result for N = {N}, C = {C} : {measurementResults}");
                    
                    
                    ResetAll(register);
                }
            }
        }
    }


    // ------------------------------------------------------
    operation T12_MeasureColor_Test () : Unit {
        for (N in 1 .. 4) {
            using (register = Qubit[N]) {
                for (C in 0 .. (1 <<< N) - 1) {
                    // prepare the register in the input state
                    InitializeColor_Reference(C, register);

                    // call the solution and verify its return value
                    let result = MeasureColor(register);
                    Fact(result == C, $"Unexpected measurement result for N = {N}, C = {C} : {result}");

                    // Message($"N = {N}, C = {C} : {result}");
                    // verify that the register remained in the same state
                    Adjoint InitializeColor_Reference(C, register);
                    AssertAllZero(register);
                }
            }
        }
    }


    // ------------------------------------------------------
    operation T13_MeasureColoring_Test () : Unit {
        for (K in 1 .. 3) {
        for (N in 1 .. 3) {
            using (register = Qubit[N * K]) {
                for (state in 0 .. (1 <<< (N * K)) - 1) {
                    // prepare the register in the input state
                    let binaryState = IntAsBoolArray(state, N * K);
                    ApplyPauliFromBitString(PauliX, true, binaryState, register);

                    // call the solution
                    let result = MeasureColoring(K, register);

                    // get the expected coloring by splitting binaryState into parts and converting them into integers
                    let partitions = Partitioned(ConstantArray(K - 1, N), binaryState);
                    let expectedColors = ForEach(FunctionAsOperation(BoolArrayAsInt), partitions);

                    // verify the return value
                    Fact(Length(result) == K, $"Unexpected number of colors for N = {N}, K = {K} : {Length(result)}");
                    for ((expected, actual) in Zip(expectedColors, result)) {
                        Fact(expected == actual, $"Unexpected color for N = {N}, K = {K} : expected {expectedColors}, got {result}");
                    }

                    // verify that the register remained in the same state
                    ApplyPauliFromBitString(PauliX, true, binaryState, register);
                    AssertAllZero(register);
                }
            }
        }
        }
    }

    // ------------------------------------------------------
    operation T16_TwoBitAdder_Test () : Unit {
        using ((register, sum, carry) = (Qubit[4], Qubit[2], Qubit())) {
            for (C in 0 .. (1 <<< 4) - 1) {
                InitializeColor(C, register);
                
                let additionItems = Chunks(2, register);
                TwoBitAdder(additionItems[0], additionItems[1], sum, carry);
                let actualsum = ResultArrayAsBoolArray(MultiM(sum));
                let actualcarry = [ResultAsBool(M(carry))];
                let actual = actualsum + actualcarry;

                let additionItemsBool = ResultArrayAsBoolArray(MultiM(register));
                let expected = BinaryAdder(additionItemsBool, 2);
                
                for (i in 0 .. 2) {
                    Fact(expected[i] == actual[i], $"Unexpected sum for C = {C}, actualsum = {actualsum}, actualcarry = {actualcarry}");
                }
                ResetAll(register);
                ResetAll(sum);
                Reset(carry);
            }
        }
    }
}