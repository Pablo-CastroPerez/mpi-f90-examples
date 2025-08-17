! Program in which 2 processes repeatedly pass a M rows of an NxN matrix back and forth.
! A version of PingPong/pingpong.f90 using derived data types, here a vector.

program pingpong

  use mpi

! Explicit declaration of variables

  implicit none

  integer :: ierr, size, rank, comm, i, length, j
  integer :: status(MPI_STATUS_SIZE)

  integer, parameter :: iter = 3             ! Number of ping pongs to be executed
  integer, parameter :: N=6, M=3             ! Matrix size (N×N) and number of rows to send
  integer, parameter :: rowstart=2           ! Start row
  integer :: mrowtype                        ! new type to be created
  integer, dimension(N,N) :: sendmatrix, recvmatrix

  comm = MPI_COMM_WORLD

  call MPI_Init(ierr)
  call MPI_Comm_rank(comm,rank,ierr)
  call MPI_Comm_size(comm,size,ierr)

  ! Code  must only run on 2 processors.

  if (size.ne.2) then
     if (rank.eq.0) write(*,*) " The code can only be run on 2 processors."
     call MPI_Finalize(ierr)
     stop
  endif

  ! Number of rows must not exceed number of columns
  ! Start row to be sent must not exceed N.

  if(M.gt.N.or.rowstart.gt.N.or.(rowstart+M).gt.(N+1))then
     write(*,*) "No. of rows MUST NOT exceed no. of columns: ", M, N, rowstart
     call MPI_Finalize(ierr)
     stop
  end if

  ! Create new datatype mrowtype to send M rows and commit it.
  
  call MPI_Type_vector(N,M,N,MPI_INTEGER,mrowtype,ierr)
  call MPI_Type_commit(mrowtype,ierr)

  ! Initialize matrices
  do i = 1, N
     do j = 1, N
        sendmatrix(i,j) = i+(j-1)*N
     end do
  end do

  if (rank.eq.0) then
     write(*,*) "Send matrix on rank 0"
     do i = 1, N
        write(*,*) sendmatrix(i,:)
     end do
  end if

  recvmatrix(:,:) = 0.0

  if(rank.eq.0)then
     write(*,30) M,N,N,rowstart,iter
  end if

30 format (1x, "Sending ", i3 ,"  cols of ", i3, " x ", i3, " matrix, starting with col ", i3 ," repeat  ",i6," times.")

  ! Run iterations using non-blocking point-to-point communications

  do i = 1, iter

     if (rank.eq.0)then

        call MPI_Ssend(sendmatrix(rowstart,1),1,mrowtype,1,50,comm,ierr)
        call MPI_Recv(recvmatrix(rowstart,1),1,mrowtype,1,60,comm,status,ierr)

     else

        call MPI_Recv(recvmatrix(rowstart,1),1,mrowtype,0,50,comm,status,ierr)
        call MPI_Ssend(sendmatrix(rowstart,1),1,mrowtype,0,60,comm,ierr)

     end if

  end do

  ! Rank 1 reports the state of the matrix after the ping-pong iterations

  if (rank .eq. 1) then
     write(*,*) "Receive matrix on rank 0"
     do i = 1, N
        write(*,*) recvmatrix(i,:)
     end do
  end if

  call MPI_Finalize(ierr)

end program pingpong
