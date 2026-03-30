//  SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
//  SPDX-License-Identifier: Apache-2.0
#include "cov_common.hpp"
#include "magic_enum.hpp"
#include "Sample.hpp"
#include "Points.hpp"

using namespace std;
using namespace ArchCov;
using namespace CovCommon;

class covSampleInterface {

  public:
    covSampleInterface() {}

    int make_packets(arch_t table) {
      int sample_done = 0;
      size_t i=0;
      for(auto entry : table.entries_) {
        Point p = static_cast<Point>(entry.first);
        if(p == Point::EndOfSim && entry.second == 1) {
          sample_done = 1;
        } else {
          cp_pkt pkt;
          pkt.cp  = entry.first;
          pkt.val = entry.second;

          //Mark the last packet of the table to indicate instruction boundary
          if(i == (table.entries_.size()-1)) {
            pkt.isLastPkt = 1;
          } else {
            pkt.isLastPkt = 0;
          }
          i++;
          sample_sv(&pkt);
        }
        if(sample_done) {
          return sample_done;
        }
      }
      return sample_done;
    }

    int sample_packets(arch_t& table) {
        int sample_done;
        sample_done = make_packets(table);
        return sample_done;
    }

};
