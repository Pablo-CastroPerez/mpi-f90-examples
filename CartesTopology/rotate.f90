
! Perform a global sum of data stored on each process by rotating each piece of data all the
! way round the ring. At each iteration, a process receives some data from the left, adds the 
! value to its running total, then passes the data it has just received on to the right.
! A version of ../Rotate/rotate.f90 using virtual topologies, here cartesian 1D

program rotate

  use mpi

  implicit none

  integer :: comm, ierr, rank, size, request,tag
  integer :: send_status(MPI_STATUS_SIZE), recv_status(MPI_STATUS_SIZE)
  integer :: left, right, addon, sum, i, passon
  
  ! New variables required
  integer :: ndims, comm1d, direction, disp
  integer :: dims(1)
  logical :: periods(1), reorder

  comm = MPI_COMM_WORLD
  tag = 1

  call MPI_Init(ierr)
  call MPI_Comm_size(comm,size,ierr)

  ! Cartesian topology
  ndims = 1
  dims(1) = 0
  periods(1) = .true.       ! Cyclic
  reorder = .false.
  direction = 0             ! Shift along the first index
  disp = 1                  ! Shift by +/- 1

  ! In 1D, dims(1) = size 

  call MPI_Dims_create(size,ndims,dims,ierr)

  ! Create cartesian communicator

  call MPI_Cart_create(comm,ndims,dims,periods,reorder,comm1d,ierr)

  ! Compute rank and neighbours in comm1d

  call MPI_Comm_rank(comm1d,rank,ierr)
  call MPI_Cart_shift(comm1d,direction,disp,left,right,ierr)

  sum = 0
  addon = 0
  
  ! Initialise local values to:
  passon = rank
 
  ! Use non-blocking point-to-point communication

  do i=1,size

     call MPI_Issend(passon,1,MPI_INTEGER,right,tag,comm1d,request,ierr)
     call MPI_Recv(addon,1,MPI_INTEGER,left,tag,comm1d,recv_status,ierr)
     call MPI_Wait(request,send_status,ierr)

     sum = sum + addon
     passon = addon

  end do

 ! Each rank reports the global sum 
  write(*,*) "The sum is: ", sum," on rank ", rank

  call MPI_Finalize(ierr)

end program rotate
