! A ring-based MPI program to compute the global sum of data stored on each process.
! Each process sends its current value to the right and receives from the left.
! Over 'size' iterations, all values are circulated around the ring and summed.

program rotate

  use mpi

 ! Explicit declaration of all variables
 
  implicit none 

  integer :: comm, ierr, rank, size, request,tag
  integer :: send_status(MPI_STATUS_SIZE), recv_status(MPI_STATUS_SIZE)
  integer :: left, right, addon, sum, i, passon

  comm = MPI_COMM_WORLD
  tag = 1

  call MPI_Init(ierr)
  call MPI_Comm_rank(comm,rank,ierr)
  call MPI_Comm_size(comm,size,ierr)

  ! Send current number to the right and receive from the left
  left = rank - 1
  right = rank + 1

  if (rank.eq.size-1) then
     right = 0
  end if

  if(rank.eq.0) then
     left = size -1
  end if

  sum = 0
  
  ! Initialise local values to:
  passon = rank
  
  ! Using non-blocking point-to-point communication. Iterating for 'size' steps. 

  do i=1,size

     call MPI_Issend(passon,1,MPI_INTEGER,right,tag,comm,request,ierr)
     call MPI_Recv(addon,1,MPI_INTEGER,left,tag,comm,recv_status,ierr)
     call MPI_Wait(request,send_status,ierr)

     sum = sum + addon
     passon = addon

  end do

  ! Each rank reports the global sum (must be equal across all ranks)
  write(*,*) "The sum is: ", sum," on rank ", rank

  call MPI_Finalize(ierr)

end program rotate
