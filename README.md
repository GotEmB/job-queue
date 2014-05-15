# Job Queue[![Build Status](https://travis-ci.org/GotEmB/job-queue.svg?branch=master)](https://travis-ci.org/GotEmB/job-queue)

A queueing system to schedule jobs and have multiple rate-limited consumers.

## API

### Setting up a Job Queue

```coffeescript
jobQueue = new JobQueue consumers, limit, period
```

|Parameter|Type|Description|
|---|---|---|
|`consumers`|**Function**|A function that will accept a *job* as the only parameter.|
|`limit`|**Integer**|The maximum number of jobs the consumer should process in `period` seconds.|
|`period`|**Integer**|The number of seconds `limit` applies to.|

### Adding Consumers

```coffeescript
jobQueue.addConsumers consumers, limit, period
```
Function signature for `addConsumers` is same as the above constructor.

### Enqueuing a Job

```coffeescript
jobQueue.enqueue job
```

|Parameter|Type|Description|
|---|---|---|
|`job`|**Anything**| The job can either be any type (`Object`, `Function`, `Number`, ...). Its type depends on what the *consumer* takes as its argument.|

### Getting Count of Pending Jobs

```coffeescript
pendingJobs = jobQueue.pendingJobs
```

## Example Usage

```coffeescript
JobQueue = require "job-queue"

makeConsumer = (consumerId) ->
	(job) ->
		console.log "Consumer #{consumerId} processing job #{job.id}"
		job.process consumerId

# Create a process queue with 5 consumers where each supports up to 5 requests per second
processQueue = new JobQueue [1..5].map(makeConsumer), 5, 1

# Add another 5 consumers to the process queue where each supports up to 80 jobs per minute
processQueue.addConsumers [6..10].map(makeConsumer), 80, 60

# Adding 10k jobs to the process queue
for jobId in [1..10000] then do (jobId) ->
	processQueue.enqueue
		id: jobId
		process: (consumerId) ->
			# The rate limited section (e.g. some API call)
			console.log "Job #{jobId} processed by consumer #{consumerId}"
```
