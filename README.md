# MPI Examples in Fortran 90

This repository contains my solutions to a set of simple parallel programming problems, implemented in Fortran 90 using the **Message Passing Interface (MPI)**.

Each exercise demonstrates a different MPI concept — from basic communication to derived datatypes and virtual topologies.

---

## Execution Notes

These examples were developed and tested on Cirrus

**Load required modules:**
```bash
module load mpt
module load intel-20.4/compilers
```
**Compilation:**
Due to the simplicity of the programs, a makefile was not produce. To compile:
```bash
mpif90 -fc=ifort -o <executable_name> <source_file>.f90
```
**To run in the login node::**
```bash
mpirun -n <number_of_processes> ./<executable_name>
```
**To run in the compute node::**
```bash
sbatch cirrusmpi.job
```

## Contents

### 1. `HelloWorld/helloworld.f90` 
A parallel version of the typical “Hello World” program.  
Each process prints "Hello World" and its rank out of the total number of processes.

### 2. `Pi/pi.f90`
Computes π via a midpoint Riemann sum of ∫₀¹ 4/(1+x²) dx with N=840 terms.  
Each process sums its own chunk (assumes N divisible by the number of processes), then rank 0 collects the partial sums via point‑to‑point messages (could be replaced by `MPI_Reduce`) to form the final π estimate and print the percent error.

### 3. `PingPong/pingpong.f90`
Two MPI processes repeatedly send a floating-point array back and forth to measure communication performance.  
Rank 0 sends the array to rank 1, which immediately sends it back. This “ping-pong” is repeated for a given number of iterations, and rank 0 reports total time, time per message, total data transferred, and effective bandwidth.  
It acts as a rudimentary measure of MPI point-to-point communication bandwidth.

### 4. `Rotate/rotate.f90`
Implements a ring-based global sum.  
Each process sends its data to the right neighbour and receives from the left, repeating until all data have circulated and been summed on every rank.  

### 5. `DerivedDataTypes`
Contains two versions of the earlier *PingPong* and *Rotate* exercises, modified to use MPI derived datatypes:

1. **pingong-derdaty.f90** – A variation of *PingPong* where `M` columns, starting at column `colstart` of an `N × N` matrix, are sent back and forth between two processes.  
   Uses `MPI_Type_vector` to describe non-contiguous column data directly in memory, avoiding manual packing/unpacking.

2. **rotate-derdaty.f90** – A variation of *Rotate* where each process passes a structure containing both an integer and a double.  
   Uses `MPI_Type_create_struct` to define a composite datatype (`int`, `double`) so both fields can be sent together in one message.


### 6. `CartesTopology/rotate.f90`
Demonstrates the use of MPI virtual topologies and collective communication for a ring-based sum:
 
 - A variation of *Rotate* that uses `MPI_Cart_create` to define a 1D Cartesian communicator with periodic boundaries (cyclic neighbour connections).  
   Neighbours are determined with `MPI_Cart_shift`, and data is passed around the ring to compute a global sum.


### 7. `BcastScatter`
Illustrates how to implement common MPI collective operations manually using point-to-point communication:

1. **bcast.f90** – The root process sends an entire array to all other processes using multiple `MPI_Ssend` calls. This mimics `MPI_Bcast` but uses explicit sends/receives.

2. **scatter.f90** – The root process splits an array into equal-sized chunks and sends each chunk to a different process using `MPI_Ssend`. This mimics `MPI_Scatter` but uses a single shared buffer.

### `cirrusmpi.job`
A generic SLURM script is included for running MPI programs on the compute nodes of Cirrus.  

