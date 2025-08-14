!  Compute an approximation of π via midpoint rule for ∫_0^1 4/(1+x^2) dx
!  Ensure each process computes a separate section of the summation
!  NOTE: here I assume that N is exactly divisible by the number of processes

program piparallel

  use mpi

  implicit none

  integer, parameter :: N = 840
  double precision :: pi, exactpi
  integer :: i

! MPI variables

  integer :: comm, rank, size, source, tag, ierr
  integer, dimension(MPI_STATUS_SIZE) :: status

! Other local variables

  integer :: istart, istop
  double precision :: partialpi, recvpi

  write(*,*) "Computing approximation to pi using N = ", N

! Initialise MPI and compute number of processes and local rank

  comm = MPI_COMM_WORLD

  call MPI_INIT(ierr)

  call MPI_COMM_SIZE(comm, size, ierr)
  call MPI_COMM_RANK(comm, rank, ierr)

  write(*,*) "Hello from rank ", rank

! Only rank 0 announces total number of processes

  if (rank == 0) write(*,*) "Running on ", size, " process(es)"

  partialpi = 0.0d0
  
! Assumes N is divisible by number of processes

  istart = N/size * rank + 1
  istop  = istart + N/size - 1

  write(*,*) "On rank ", rank, " istart = ", istart, ", istop = ", istop
  
! Compute local partial sum for pi/4

  do i = istart, istop
  
     partialpi = partialpi + 1.0d0/(1.0d0+((dble(i)-0.5d0)/dble(N))**2)
  
  end do

  write(*,*) "On rank ", rank, " partialpi = ", partialpi * 4.0d0/dble(N)

! Compute global value of pi by sending partial values to rank 0
! NOTE: this would be more efficiently done using MPI_REDUCE

  if (rank == 0) then

! initialise pi to locally computed partial sum

    pi = partialpi

! add in contributions from other processes

    do source = 1, size-1

! Receive partialpi from *any* source and place value in recvpi
! All messages are tagged as zero

       tag = 0

       call MPI_RECV(recvpi, 1, MPI_DOUBLE_PRECISION, MPI_ANY_SOURCE, &
                     tag, comm, status, ierr)

       write(*,*) "rank 0 receiving from rank ", status(MPI_SOURCE)

! Add to running total

       pi = pi + recvpi

    end do

  else

! All other processes send their partial value to rank 0

     write(*,*) "rank ", rank, " sending to rank 0"

     tag = 0

     call MPI_SSEND(partialpi, 1, MPI_DOUBLE_PRECISION, 0, &
                    tag, comm, ierr)
  end if

  pi = pi * 4.0d0/dble(N)

  exactpi = 4.0d0*atan(1.0d0)

  if (rank == 0) then
     write(*,*) "pi = ", pi, ", % error = ", abs(100.0d0*(pi-exactpi)/exactpi)
  end if

! Finalise MPI

  call MPI_FINALIZE(ierr)

end program piparallel
