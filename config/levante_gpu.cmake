iif ( NOT BUILD_TYPE )
   message( WARNING "Setting CMAKE_BUILD_TYPE to default value." )
   set(BUILD_TYPE BIG)
endif()

if ( ${BUILD_TYPE} STREQUAL "PARALLEL" ) # compiler for parallel build
  set(ENV{FC} mpif90)
  set(CMAKE_Fortran_COMPILER mpif90)
  set(USER_Fortran_FLAGS "-cpp -ffree-form -ffree-line-length-none -fno-automatic")
  set(USER_Fortran_FLAGS_RELEASE "-fconvert=little-endian -fallow-argument-mismatch -O3 -ffast-math -mtune=native -march=native")
  add_definitions(-DUSE_FFTW -DUSE_MPI -DUSE_MPI_IO)
  set(CMAKE_BUILD_TYPE RELEASE)

elseif(${BUILD_TYPE} STREQUAL "GPU" ) # Compiler for gpu acceleration 
  set(ENV{FC} nvfortran)
  set(CMAKE_Fortran_COMPILER nvfortran)
  set(CMAKE_Fortran_FLAGS "-acc=verystrict,gpu -target=gpu -Minfo=accel,inline -gpu=cc80,lineinfo -pg -Mfree -cpp -Mfree")
  #set(USER_Fortran_FLAGS_DEBUG "-O0 -pg -ggdb -Wall -fbacktrace -ffpe-summary=all")
  #set(USER_Fortran_FLAGS "-cpp -ffree-form -ffree-line-length-none -fno-automatic")
  #set(CMAKE_Fortran_FLAGS "-acc=gpu -target=gpu -Minfo=accel,inline -gpu=lineinfo,cc80 -cpp")#gpu=ccnative
  add_definitions(-D_DEBUG)
  set(CMKAE_BUILD_TYPE DEBUG)

else() # compiler for serial build
  set(ENV{FC} gfortran)
  set(CMAKE_Fortran_COMPILER gfortran)
  set(USER_Fortran_FLAGS "-cpp -ffree-form -ffree-line-length-none -fno-automatic")
  add_definitions(-DUSE_FFTW)

  if    ( ${BUILD_TYPE} STREQUAL "BIG" )
          set(USER_Fortran_FLAGS_RELEASE "-fconvert=big-endian -fallow-argument-mismatch -ffpe-summary=none -O3 -ffast-math -mtune=native -march=native")
    set(CMAKE_BUILD_TYPE RELEASE)

  elseif( ${BUILD_TYPE} STREQUAL "LITTLE" )
          set(USER_Fortran_FLAGS_RELEASE "-fconvert=little-endian -fallow-argument-mismatch -ffpe-summary=none -O3 -ffast-math -mtune=native -march=native")
    set(CMAKE_BUILD_TYPE RELEASE)

  else()
    set(USER_Fortran_FLAGS_DEBUG "-O0 -p -ggdb -Wall -fbacktrace -ffpe-summary=all")
    #set(USER_Fortran_FLAGS_DEBUG "-O0 -ggdb -pg -Wall -fbacktrace -fconvert=little-endian -fallow-argument-mismatch -ffpe-trap=invalid,zero,overflow")
    add_definitions(-D_DEBUG)
    set(CMAKE_BUILD_TYPE DEBUG)

  endif()

endif()

#https://docs.dkrz.de/doc/levante/code-development/compiling-and-linking.html#libraries-from-the-software-tree
#set(FFTW_INCLUDE_DIR   "/usr/local/include")
#set(FFTW_LIB           "/usr/local/lib/libfftw3.a")
set(FFTW_LIB           "-lfftw3")
set(INCLUDE_DIRS ${FFTW_INCLUDE_DIR})
set(LIBS ${FFTW_LIB})

add_definitions(-DUSE_NETCDF)
#set(NC_INCLUDE_DIR     "/sw/buster-x64/io/netcdf-c-4.7.4-fortran-4.5.2-cxx4-4.3.1-cxx-4.2-gccsys/include")
#set(NC_LIB             "-L/sw/buster-x64/io/netcdf-c-4.7.4-fortran-4.5.2-cxx4-4.3.1-cxx-4.2-gccsys/lib -Wl,-rpath -Wl,/sw/buster-x64/io/netcdf-c-4.7.4-fortran-4.5.2-cxx4-4.3.1-cxx-4.2-gccsys/lib -lnetcdff")
set(NC_INCLUDE_DIR     "/sw/spack-levante/netcdf-fortran-4.5.3-k6xq5g/include")
set(NC_LIB             "-I/sw/spack-levante/netcdf-fortran-4.5.3-k6xq5g/include \
                        -L/sw/spack-levante/netcdf-fortran-4.5.3-k6xq5g/lib -lnetcdff \
                        -Wl,-rpath,/sw/spack-levante/netcdf-fortran-4.5.3-k6xq5g/lib")
set(INCLUDE_DIRS ${INCLUDE_DIRS} ${NC_INCLUDE_DIR})
set(LIBS ${LIBS} ${NC_LIB})
