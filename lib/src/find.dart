// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: BSD-3-Clause
//
// find.dart
// Implementation of Find Functionality.
//
// 2023 July 11
// Author: Rahul Gautham Putcha <rahul.gautham.putcha@intel.com>
//

import 'package:rohd/rohd.dart';
import 'package:rohd_hcl/rohd_hcl.dart';

/// Find functionality
///
/// Takes in a [Logic] to find location of `1`s or `0`s.
/// Outputs pin `index` contains position.
class Find extends Module {
  /// [index] is an getter for output of Find
  Logic get index => output('index');

  /// [error] is an getter for error in Find
  /// When your find is not found it will result in error `1`
  Logic get error => output('error');

  /// Find `1`s or `0`s
  ///
  /// Takes in filter search parameter [countOne], default [Find] `1`.
  /// If [countOne] is `true` [Find] `1` else [Find] `0`.
  ///
  /// By default [Find] will look for first search parameter `1` or `0`.
  /// If [n] is given, [Find] an [n]th search from first occurance.
  ///
  /// Outputs pin `index` contains position.
  Find(Logic bus, {bool countOne = true, Logic? n}) {
    bus = addInput('bus', bus, width: bus.width);
    final oneHotList = <Logic>[];

    if (n != null) {
      n = addInput('n', n, width: n.width);
    }

    // 00000000 [0, 0]
    for (var i = 0; i < bus.width; i++) {
      // determines if it is what we are looking for?
      final valCheck = countOne ? bus[i] : ~bus[i];

      final count = Count(bus.getRange(0, i + 1), countOne: countOne);

      // Below code will make `n` comparable to `count`
      var paddedCountValue = count.index;
      var paddedNValue = (n ?? Const(0)) + 1;

      if (paddedNValue.width < paddedCountValue.width) {
        paddedNValue = paddedNValue.zeroExtend(paddedCountValue.width);
      } else {
        paddedCountValue = paddedCountValue.zeroExtend(paddedNValue.width);
      }

      // If bus[i] contains search value (0/1) and it is nth position
      // then append Logic `1` else append Logic `0`
      oneHotList.add(valCheck & paddedNValue.eq(paddedCountValue));
    }

    final oneHotBinary = OneHotToBinary(oneHotList.rswizzle());
    // Upon search complete, we get the position value in binary `bin` form
    final bin = oneHotBinary.binary;
    addOutput('index', width: bin.width);
    index <= bin;

    addOutput('error');
    error <= oneHotBinary.error;
  }
}
