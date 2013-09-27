#include <stdlib.h>
#include <stdio.h>
#include <libcpuid.h>
#include <zmq.h>
#include <string.h>
#include <assert.h>
#include "str.h"

char* serialize(char* vendor, char* brand) {
  char* resp;
  int len = snprintf(NULL, 0, "%s, %s", vendor, brand);
  resp = (char *)malloc(len + 1);
  sprintf(resp, "%s,%s", vendor, brand);
  return resp;
}
int main() {
  struct cpu_raw_data_t raw;                                             // contains only raw data
  struct cpu_id_t data;                                                  // contains recognized CPU features data

  void *context = zmq_ctx_new();
  void *responder = zmq_socket(context, ZMQ_REP);
  int rc = zmq_bind(responder, "tcp://127.0.0.1:5555");
  assert(rc == 0);

  printf("Binded on 127.0.0.1:5555\n");

  while (1) {
    char buffer [30];
#if ZMQ_VERSION_MAJOR == 3
    zmq_recv(responder, buffer, 30, 0);
#elif ZMQ_VERSION_MINOR == 2
    zmq_recv(responder, buffer, 0);
#endif
    printf("Received\n");

    char *resp;
    
    if (cpuid_get_raw_data(&raw) < 0) {                                    // obtain the raw CPUID data
      printf("Sorry, cannot get the CPUID raw data.\n");
      printf("Error: %s\n", cpuid_error());                          // cpuid_error() gives the last error description
      return -2;
    }
    
    if (cpu_identify(&raw, &data) < 0) {                                   // identify the CPU, using the given raw data.
      printf("Sorrry, CPU identification failed.\n");
      printf("Error: %s\n", cpuid_error());
      return -3;
    }
    
    //int len = snprintf(NULL, 0, "%s, %s", data.vendor_str, data.brand_str);
    //resp = (char *)malloc(len + 1);
    //sprintf(resp, "%s,%s", data.vendor_str, data.brand_str);
    resp = serialize(data.vendor_str, data.brand_str);

#if ZMQ_VERSION_MAJOR == 3
    zmq_send(responder, resp, strlen(resp), 0);
#elif ZMQ_VERSION_MINOR == 2
    zmq_send(responder, resp, 0);
#endif
    sleep(1);
  }

  if (cpuid_get_raw_data(&raw) < 0) {                                    // obtain the raw CPUID data
    printf("Sorry, cannot get the CPUID raw data.\n");
    printf("Error: %s\n", cpuid_error());                          // cpuid_error() gives the last error description
    return -2;
  }
  
  if (cpu_identify(&raw, &data) < 0) {                                   // identify the CPU, using the given raw data.
    printf("Sorrry, CPU identification failed.\n");
    printf("Error: %s\n", cpuid_error());
    return -3;
  }

  printf("Found: %s CPU\n", data.vendor_str);                            // print out the vendor string (e.g. `GenuineIntel')
  printf("Processor model is `%s'\n", data.cpu_codename);                // print out the CPU code name (e.g. `Pentium 4 (Northwood)')
  printf("The full brand string is `%s'\n", data.brand_str);             // print out the CPU brand string
  printf("The processor has %dK L1 cache and %dK L2 cache\n",
    data.l1_data_cache, data.l2_cache);                            // print out cache size information
  printf("The processor has %d cores and %d logical processors\n",
    data.num_cores, data.num_logical_cpus);                        // print out CPU cores information

  printf("hola!");
  printf("CPU clock is: %d MHz (according to your OS)\n", cpu_clock_by_os());  // print out the CPU clock, according to the OS
  printf("CPU clock is: %d MHz (tested)\n", cpu_clock_measure(200, 0));
  return 0;
}
