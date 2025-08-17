
! A version of the rotate exercise from ../Rotate/rotate.f90 using derived data types

program derdaty

  use mpi
  
  implicit none

  type compound
     integer :: ival
     double precision :: dval
  end type compound

  ! introduce new variables related to derived datatypes
  type(compound) :: passon,addon,sum
  integer :: blocklen(2), type(2)
  integer (kind=MPI_ADDRESS_KIND), dimension(2) :: disp
  integer (kind=MPI_ADDRESS_KIND) :: base
  integer :: newtype

  ! old variables as already used for the rotate.f90 code
  integer :: comm, ierr, rank, size, request
  integer :: send_status(MPI_STATUS_SIZE), recv_status(MPI_STATUS_SIZE)
  integer :: left, right, i, tag

  comm = MPI_COMM_WORLD
  tag = 1

  call MPI_Init(ierr)
  call MPI_Comm_rank(comm,rank,ierr)
  call MPI_Comm_size(comm,size,ierr)

  ! Create all necessary info for the derived datatype
  call MPI_Get_address(passon%ival,disp(1),ierr)
  call MPI_Get_address(passon%dval,disp(2),ierr)

  ! Compute relative displacements
  disp(2) = disp(2) - disp(1)
  disp(1) = 0

  blocklen(1) = 1
  blocklen(2) = 1

  type(1) = MPI_INTEGER
  type(2) = MPI_DOUBLE_PRECISION

  ! Create the new datatype, called "newtype" and commit it
  call MPI_Type_create_struct(2,blocklen,disp,type,newtype,ierr)
  call MPI_Type_commit(newtype,ierr)

  ! Send current number to the right and receive from the left
  left = rank - 1
  right = rank + 1

  if (rank.eq.size-1) then
     right = 0
  end if

  if(rank.eq.0) then
     left = size -1
  end if

  sum%ival = 0
  sum%dval = 0.0

  ! Initialise local values to:
  passon%ival = rank
  passon%dval = (rank+1)**2

  ! Using non-blocking point-to-point communication 

  do i=1,size

     call MPI_Issend(passon,1,newtype,right,tag,comm,request,ierr)
     call MPI_Recv(addon,1,newtype,left,tag,comm,recv_status,ierr)
     call MPI_Wait(request,send_status,ierr)

     sum%ival = sum%ival + addon%ival
     sum%dval = sum%dval + addon%dval

     passon = addon

  end do

  ! Each rank reports the total sum
  write(*,*)"The sum is: ", sum, " on rank ", rank

  call MPI_Finalize(ierr)

end program
