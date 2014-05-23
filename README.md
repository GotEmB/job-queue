# Job Queue [![Build Status](https://travis-ci.org/GotEmB/job-queue.svg?branch=master)](https://travis-ci.org/GotEmB/job-queue)

A queueing system to schedule jobs and have multiple rate-limited consumers.

## API

### Job Queue

Setting up a job queue:

```coffeescript
jobQueue = new JobQueue consumers
```

|Parameter|Type|Description|
|---|---|---|
|`consumers`|**Consumer**|A consumer (e.g. `MovingWindowRateLimitedConsumer`, `CustomRateLimitedConsumer`).|

Adding consumers:

```coffeescript
jobQueue.addConsumers consumers
```
Function signature for `addConsumers` is same as the above constructor.

Enqueuing a job:

```coffeescript
jobQueue.enqueue job
```

|Parameter|Type|Description|
|---|---|---|
|`job`|**Anything**| The job can either be any type (`Object`, `Function`, `Number`, ...). Its type depends on what the *consumer* takes as its argument.|

Getting count of pending jobs:

```coffeescript
pendingJobs = jobQueue.pendingJobs
```

### Consumers

There are two consumer types included in this package (`MovingWindowRateLimitedConsumer` and `CustomRateLimitedConsumer`).

#### MovingWindowRateLimitedConsumer

Use this consumer type to create a consumer that should be restricted by a moving-window rate-limit.

Create one using:

```coffeescript
consumer = new MovingWindowRateLimitedConsumer consume, limit, period
```

|Parameter|Type|Description
|---|---|---|
|`consume`|**Function**|A function that will accept a *job* as the only parameter.|
|`limit`|**Integer**|The maximum number of jobs the consumer should process in `period` milliseconds.|
|`period`|**Integer**|The number of milliseconds `limit` applies to.|

#### CustomRateLimitedConsumer

Use this consumer type to create a consumer to which you would provide a custom scheduling algorithm.

Create one using:

```coffeescript
consumer = new CustomRateLimitedConsumer consume, getNextTimestamp
```

|Parameter|Type|Description
|---|---|---|
|`consume`|**Function**|A function that will accept a *job* as the only parameter.|
|`getNextTimestamp`|**Function**|A function that will be called when a job is to be scheduled. Should return a `Date`.|

If defining your own consumer type, they must provide the following functions:

|Method|Required|Description|
|---|---|---|---|---|
|`consume`|Yes|This function will be called when a job should be executed. It will be called with `job` as its parameter.|
|`getNextTimestamp`|Yes|This function is called when a job is to be inserted. Should return the closest time (a `Date`) when the next job can be scheduled using this consumer. Return `new Date` if a job can be scheduled immediately.|
|`usedTimestamp`|No|This function will be called when a job is scheduled using this consumer. It will be called with `timestamp` (a `Date`) as its parameter.|

## Example Usage

```coffeescript
JobQueue = require "job-queue"

makeConsumer = (consumerId, period, limit) ->
	new MovingWindowRateLimitedConsumer (job) ->
		console.log "Consumer #{consumerId} processing job #{job.id}"
		job.process consumerId
	, period, limit

# Create a process queue with 5 consumers where each supports up to 5 requests per second
processQueue = new JobQueue [1..5].map (consumerId) -> makeConsumer consumerId, 5, 1000

# Add another 5 consumers to the process queue where each supports up to 80 jobs per minute
processQueue.addConsumers [6..10].map (consumerId) -> makeConsumer consumerId, 80, 60 * 1000

# Adding 10k jobs to the process queue
for jobId in [1..10000] then do (jobId) ->
	processQueue.enqueue
		id: jobId
		process: (consumerId) ->
			# The rate limited section (e.g. some API call)
			console.log "Job #{jobId} processed by consumer #{consumerId}"
```
