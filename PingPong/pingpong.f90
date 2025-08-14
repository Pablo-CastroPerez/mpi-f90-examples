! Program in which 2 processes repeatedly pass a message back and forth
! Two processes repeatedly exchange a floating-point array to measure bandwidth.
! Rank 0 sends to Rank 1 (tag 1), and Rank 1 sends back to Rank 0 (tag 2).

program pingpong

  use mpi

  implicit none

  integer :: ierr, size, rank, comm, i, length, numiter
  integer :: status(MPI_STATUS_SIZE)
  integer :: tag1, tag2, realsize
  character*10 temp_char10
  integer :: iargc
  real, allocatable :: sbuffer(:)
  double precision :: tstart, tstop, time, totmess

  comm = MPI_COMM_WORLD
  tag1 = 1
  tag2 = 2

  call MPI_Init(ierr)
  call MPI_Comm_rank(comm,rank,ierr)
  call MPI_Comm_size(comm,size,ierr)

  ! Require at least 2 processes
  if(size.lt.2) then
     if(rank.eq.0) write(*,*) "The code must be run on at least 2 processes"
     call MPI_Finalize(ierr)
     stop
  endif

  ! Require two CLI arguments: <array length> <number of iterations>
  if (iargc() /= 2) then
     if (rank .eq. 0) then
        write(*,*) "Usage: pingpong <array length> <number of iterations>"
     end if

     call MPI_Finalize(ierr)
     stop
  end if

 ! Only ranks 0 and 1 participate in the ping-pong; others report and idle
  if (rank.gt.1) then
     write(*,*) "Rank ", rank, " not participating"
  end if


  if (rank .eq. 0) then 
     call getarg(1,temp_char10)
     read(temp_char10,*) length
     call getarg(2,temp_char10)
     read(temp_char10,*) numiter

     write(*,*) "Array length, number of iterations = ", length, numiter
  end if

  call MPI_Bcast(length,1,MPI_INTEGER,0,comm,ierr)
  call MPI_Bcast(numiter,1,MPI_INTEGER,0,comm,ierr)


  ! Allocate array
  allocate(sbuffer(length))

  ! Send "buffer" back and forth between rank 0 and rank 1.
  do i=1,length
     sbuffer(i) = rank + 10.0
  enddo

  ! Start timing the parallel part here.
  call MPI_Barrier(comm,ierr)
  tstart = MPI_Wtime()

  do i=1,numiter
     if (rank.eq.0)then
        call MPI_Ssend(sbuffer(1),length,MPI_REAL,1,tag1,comm,ierr)
        call MPI_Recv(sbuffer(1),length,MPI_REAL,1,tag2,comm,status,ierr)

     else if (rank.eq.1)then
        call MPI_Recv(sbuffer(1),length,MPI_REAL,0,tag1,comm,status,ierr)
        call MPI_Ssend(sbuffer(1),length,MPI_REAL,0,tag2,comm,ierr)
     endif
  enddo


  tstop = MPI_Wtime()
  time  = tstop - tstart

  ! Report results from rank 0
  call MPI_Type_size(MPI_REAL,realsize,ierr)

  if(rank.eq.0)then
     totmess = 2.d0*realsize*length/1024.d0*numiter/1024.d0
     write(*,*) "Ping-Pong of twice ",realsize*length," bytes, for ",numiter," times."
     write(*,*) "Total computing time is ",time," [s]."
     write(*,*) "Total message size is ",totmess," [MiB]."
     write(*,*) "Time per message is ", time/numiter*0.5d0,"[s]."
     write(*,*) "Bandwidth is ",totmess/time," [MiB/s]."

     if(time.lt.1.d0)then
        write(*,*) "WARNING: The time is too short to be trusted."
        write(*,*) "WARNING: Increase the number of iterations and/or the array size"
        write(*,*) "WARNING: so time is at least one second!"

     endif
  endif

  deallocate(sbuffer)

  call MPI_Finalize(ierr)

end program pingpong
