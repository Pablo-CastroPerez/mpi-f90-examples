
! Simple program to implement a broadcast using point-to-point communications
! It replicates the behaviour of MPI_Scatter().

program scatter

  use mpi

! Explicit variable declaration

  implicit none

  integer :: i, src, dest, rank, size, root, tag, count, ierr
  integer :: comm
  integer, dimension(MPI_STATUS_SIZE) :: status

  integer, parameter :: N = 12 ! Global array length on the root

  integer, dimension(N) :: x

  comm = MPI_COMM_WORLD
  root = 0   ! The process that contains the data to be scatter

  call MPI_Init(ierr)

  call MPI_Comm_size(comm, size, ierr)
  call MPI_Comm_rank(comm, rank, ierr)

  if (rank == 0) write(*,*) "Running scatter program on ", size, " processes"

  do i = 1, N

     if (rank == root) then
        x(i) = i-1
     else
        x(i) = -1
     end if

  end do

  write(*,*) "On rank ", rank, " x = ", x(:)

  count = N/size;   ! Assumes N is divisible by size

  tag = 0

! Non-blocking point to point communications

  if (rank == root) then

     do dest = 0, size-1

        if (dest /= root) call MPI_Ssend(x(dest*count+1), count, MPI_INTEGER, dest, tag, comm, ierr)  ! Root sends data to each rank

     end do

  else

     call MPI_Recv(x, count, MPI_INTEGER, root, tag, comm, status, ierr)   ! Non-root ranks receive their 'count' integers

  end if

  write(*,*) "On rank ", rank, " x = ", x(:)

  call MPI_Finalize(ierr)

end program scatter
