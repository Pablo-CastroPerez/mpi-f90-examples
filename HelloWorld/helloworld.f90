! Prints "Hello World" from rank 0 and prints what processor it is out
! of the total number of processors from all ranks

program helloworld

  use mpi

  implicit none

  integer :: comm, rank, size, ierr

  comm = MPI_COMM_WORLD

  call MPI_Init(ierr)

  call MPI_Comm_rank(comm, rank, ierr)
  call MPI_Comm_size(comm, size, ierr)

  ! Only processor 0 prints 
  if(rank.eq.0) write(*,*) "Hello World!"

  ! Each process prints out its rank
  write(*,*) "This is ", rank, "out of ", size," processes"

  call MPI_Finalize(ierr)

end program helloworld
