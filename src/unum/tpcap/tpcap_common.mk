# Copyright 2019 - 2020 Minim Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Common Makefile for packet capturing job

# Add platform folder to the include search path 
CPPFLAGS += -I$(UNUM_PATH)/tpcap/$(MODEL)

# Add code file(s)
OBJECTS += \
  ./tpcap/tpcap.o       \
  ./tpcap/process_pkt.o \
  ./tpcap/$(MODEL)/tpcap_platform.o

# Add subsystem initializer function
INITLIST += tpcap_init

