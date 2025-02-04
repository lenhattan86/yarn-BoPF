/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair;

import java.util.ArrayList;

import org.apache.hadoop.yarn.api.records.Priority;
import org.apache.hadoop.yarn.api.records.Resource;
import org.apache.hadoop.yarn.server.resourcemanager.RMContext;
import org.apache.hadoop.yarn.server.resourcemanager.resource.ResourceWeights;
import org.apache.hadoop.yarn.server.resourcemanager.rmapp.RMAppMetrics;
import org.apache.hadoop.yarn.server.resourcemanager.rmcontainer.RMContainer;
import org.apache.hadoop.yarn.server.resourcemanager.scheduler.Queue;
import org.apache.hadoop.yarn.util.Records;
import org.apache.hadoop.yarn.util.resource.Resources;

/**
 * Dummy implementation of Schedulable for unit testing.
 */
public class FakeSchedulable implements Schedulable {
  private Resource usage;
  private Resource minShare;
  private Resource maxShare;
  private Resource fairShare;
  private ResourceWeights weights;
  private Priority priority;
  private long startTime;
  private float fairPriority = 1.0f;
  private Resource minReq;

  public FakeSchedulable() {
    this(0, Integer.MAX_VALUE, 1, 0, 0, 0);
  }

  public FakeSchedulable(long startTime, float fairPriority) {
    this(0, Integer.MAX_VALUE, 1, 0, 0, startTime, fairPriority);
  }

  public FakeSchedulable(int minShare) {
    this(minShare, Integer.MAX_VALUE, 1, 0, 0, 0);
    minReq = this.getMinShare();
  }

  public FakeSchedulable(int minShare, int maxShare) {
    this(minShare, maxShare, 1, 0, 0, 0);
  }

  public FakeSchedulable(int minShare, int maxShare, int minReq) {
    this(minShare, maxShare, 1, 0, 0, 0);
  }

  public FakeSchedulable(int minShare, double memoryWeight) {
    this(minShare, Integer.MAX_VALUE, memoryWeight, 0, 0, 0);
  }

  public FakeSchedulable(int minShare, int maxShare, double memoryWeight) {
    this(minShare, maxShare, memoryWeight, 0, 0, 0);
  }

  public FakeSchedulable(int minShare, int maxShare, double weight, int fairShare, int usage, long startTime) {
    this(Resources.createResource(minShare, 0), Resources.createResource(maxShare, 0),
        new ResourceWeights((float) weight), Resources.createResource(fairShare, 0), Resources.createResource(usage, 0),
        startTime);
  }

  public FakeSchedulable(int minShare, int maxShare, double weight, int fairShare, int usage, long startTime,
      float fairPrirotity) {
    this(Resources.createResource(minShare, 0), Resources.createResource(maxShare, 0),
        new ResourceWeights((float) weight), Resources.createResource(fairShare, 0), Resources.createResource(usage, 0),
        startTime, fairPrirotity);
  }

  public FakeSchedulable(Resource minShare, ResourceWeights weights) {
    this(minShare, Resources.createResource(Integer.MAX_VALUE, Integer.MAX_VALUE), weights,
        Resources.createResource(0, 0), Resources.createResource(0, 0), 0);
  }

  public FakeSchedulable(Resource minShare, Resource maxShare, ResourceWeights weight, Resource fairShare,
      Resource usage, long startTime) {
    this.minShare = minShare;
    this.maxShare = maxShare;
    this.weights = weight;
    setFairShare(fairShare);
    this.usage = usage;
    this.priority = Records.newRecord(Priority.class);
    this.startTime = startTime;
  }

  public FakeSchedulable(Resource minShare, Resource maxShare, ResourceWeights weight, Resource fairShare,
      Resource usage, long startTime, float fairPriority) {
    this.minShare = minShare;
    this.maxShare = maxShare;
    this.weights = weight;
    setFairShare(fairShare);
    this.usage = usage;
    this.priority = Records.newRecord(Priority.class);
    this.startTime = startTime;
    this.fairPriority = fairPriority;
  }

  public FakeSchedulable(Resource minShare, Resource maxShare, ResourceWeights weights, Resource none, Resource usage,
      long l, Resource minReq) {
    this.minShare = minShare;
    this.maxShare = maxShare;
    this.weights = weights;
    setFairShare(fairShare);
    this.usage = usage;
    this.priority = Records.newRecord(Priority.class);
    this.startTime = 0;
    this.minReq = minReq;
  }

  @Override
  public Resource assignContainer(FSSchedulerNode node) {
    return null;
  }

  @Override
  public RMContainer preemptContainer() {
    return null;
  }

  @Override
  public Resource getFairShare() {
    return this.fairShare;
  }

  @Override
  public void setFairShare(Resource fairShare) {
    this.fairShare = fairShare;
  }

  @Override
  public Resource getDemand() {
    return null;
  }

  @Override
  public String getName() {
    return "FakeSchedulable" + this.hashCode();
  }

  @Override
  public Priority getPriority() {
    return priority;
  }

  @Override
  public Resource getResourceUsage() {
    return usage;
  }

  @Override
  public long getStartTime() {
    return startTime;
  }

  @Override
  public ResourceWeights getWeights() {
    return weights;
  }

  @Override
  public Resource getMinShare() {
    return minShare;
  }

  @Override
  public Resource getMaxShare() {
    return maxShare;
  }

  @Override
  public void updateDemand() {
  }

  @Override
  public float getFairPriority() {// iglf
    return fairPriority;
  }

  public void setFairPriority(float fairPriority) {
    this.fairPriority = fairPriority;
  }

  @Override
  public Resource getGuaranteeShare() {
    return this.minReq;
  }

  @Override
  public RMContext getRMContext() { // iglf
    // TODO Auto-generated method stub
    return null;
  }

  @Override
  public Queue getParentQueue() {
    // TODO Auto-generated method stub
    return null;
  }

  @Override
  public long getStage1Duration() {
    // TODO Auto-generated method stub
    return 0;
  }

  @Override
  public long getPeriod() {
    // TODO Auto-generated method stub
    return 0;
  }

  @Override
  public boolean isLeafQueue() {
    // TODO Auto-generated method stub
    return false;
  }

  @Override
  public Resource getAlpha() {
    // TODO Auto-generated method stub
    return null;
  }

  public boolean isRunning() {
    return true;
  }

  @Override
  public boolean isAdmitted() {
    // TODO Auto-generated method stub
    return false;
  }

  @Override
  public boolean isBursty() {
    // TODO Auto-generated method stub
    return false;
  }

  @Override
  public boolean isRejected() {
    // TODO Auto-generated method stub
    return false;
  }

  @Override
  public boolean isNewArrival() {
    // TODO Auto-generated method stub
    return false;
  }

  @Override
  public boolean isHardGuaranteed() {
    // TODO Auto-generated method stub
    return false;
  }

  @Override
  public boolean isSoftGuaranteed() {
    // TODO Auto-generated method stub
    return false;
  }

  @Override
  public String getAppName() {
    // TODO Auto-generated method stub
    return null;
  }

  @Override
  public RMAppMetrics getAppMetrics(){
    return null;
  }

  @Override
  public void setGuaranteeShare(Resource res) {
    // TODO Auto-generated method stub
    
  }
}
