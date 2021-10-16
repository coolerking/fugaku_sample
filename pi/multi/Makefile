CC=mpifccpx
#CC=mpifcc
CFLAGS=-Kfast,openmp

all: MPI_Pi

MPI_Pi: MPI_Pi.c
	$(CC) $(CFLAGS)  MPI_Pi.c -o MPI_Pi
clean:
	rm -rf MPI_Pi
	rm -rf ./MPI_Pi.sh.*.err ./MPI_Pi.sh.*.out ./MPI_Pi.sh.*.stats
	rm -rf ./MPI_Pi.sh.*.err/* ./MPI_Pi.sh.*.out.* ./MPI_Pi.sh.*.stats.*