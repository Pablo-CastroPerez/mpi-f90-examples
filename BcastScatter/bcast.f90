
! Simple program to implement a broadcast using point-to-pointcommunications. 
! It replicates the behaviour of the built in function MPI_Bcast()

program bcast

  use mpi

! Explicit variable declaration
  implicit none

  integer :: i, src, dest, rank, size, root, tag, ierr
  integer :: comm
  integer, dimension(MPI_STATUS_SIZE) :: status

  integer, parameter :: N = 12  ! Length of the data array

  integer, dimension(N) :: x    ! Local data array

  comm = MPI_COMM_WORLD
  root = 0   ! Rank zero contains the data to be broadcast

  call MPI_Init(ierr)

  call MPI_Comm_size(comm, size, ierr)
  call MPI_Comm_rank(comm, rank, ierr)

  if (rank == 0) write(*,*) "Running broadcast program on ", size, " processes"


! Initialise data
  do i = 1, N

     if (rank == root) then
        x(i) = i-1
     else
        x(i) = -1
     end if

  end do

  write(*,*) "On rank ", rank, " x = ", x(:)

  tag = 0

  if (rank == root) then
  
     do dest = 0, size-1
        if (dest /= root) call MPI_Ssend(x, N, MPI_INTEGER, dest, tag, comm, ierr)  ! Rank zero sends data to all other ranks
     end do
     
  else
     call MPI_Recv(x, N, MPI_INTEGER, root, tag, comm, status, ierr)  ! Ranks other than zero receive the data
  end if

  write(*,*) "On rank ", rank, " x = ", x(:)

  call MPI_Finalize(ierr)

end program bcast
