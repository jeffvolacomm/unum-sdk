// Copyright 2019 - 2020 Minim Inc
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// unum device specifc test stubs
// using weak reference so platforms can implement their own

#include "unum.h"

// Compile only in debug version
#ifdef DEBUG

// Test load config
int __attribute__((weak)) test_loadCfg(void)
{
    printf("Test %d is not implemented for the platform\n",
           get_test_num());
    return 0;
}

// Test save config
int __attribute__((weak)) test_saveCfg(void)
{
    printf("Test %d is not implemented for the platform\n",
           get_test_num());
    return 0;
}

// Test wireless
void __attribute__((weak)) test_wireless(void)
{
    printf("Test %d is not implemented for the platform\n",
           get_test_num());
}

// Test festats
int __attribute__((weak)) test_festats(void)
{
    printf("Test %d is not implemented for the platform\n",
           get_test_num());
    return 0;
}

// Test festats defrag
int __attribute__((weak)) test_fe_defrag(void)
{
    printf("Test %d is not implemented for the platform\n",
           get_test_num());
    return 0;
}

// Test festats ARP tracker
int __attribute__((weak)) test_fe_arp(void)
{
    printf("Test %d is not implemented for the platform\n",
           get_test_num());
    return 0;
}

// Test TCP port scanner
void __attribute__((weak)) test_port_scan(void)
{
    printf("Test %d is not implemented for the platform\n",
           get_test_num());
    return;
}
#endif // DEBUG
