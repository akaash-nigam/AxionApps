# Load Testing

Comprehensive load testing suite for the Spatial Meeting Platform API using k6.

## Prerequisites

Install k6:

**macOS:**
```bash
brew install k6
```

**Linux:**
```bash
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6
```

**Windows:**
```powershell
choco install k6
```

## Test Suites

### 1. API Load Test (`api-load-test.js`)

Tests basic API functionality under load.

```bash
k6 run api-load-test.js
```

**Scenarios:**
- User registration
- Meeting creation
- Meeting retrieval
- Profile management

**Load Profile:**
- Ramp to 20 VUs (30s)
- Ramp to 50 VUs (1m)
- Sustain 50 VUs (2m)
- Ramp down (30s)

**Thresholds:**
- P95 response time < 500ms
- Error rate < 10%

### 2. Meeting Load Test (`meeting-load-test.js`)

Simulates concurrent meeting creation and joining.

```bash
k6 run meeting-load-test.js
```

**Scenarios:**
- 10 VUs creating meetings
- 50 VUs joining existing meetings

**Metrics Tracked:**
- Meeting creation count
- Meeting join count
- Participant count per meeting

**Thresholds:**
- P95 response time < 1000ms
- Error rate < 5%

### 3. WebSocket Load Test (`websocket-load-test.js`)

Tests real-time WebSocket connections and messaging.

```bash
k6 run websocket-load-test.js
```

**Scenarios:**
- 50 concurrent WebSocket connections
- Position updates (10 per connection)
- Audio/video state updates
- Message broadcasting

**Thresholds:**
- Connection time < 1s
- Minimum 100 messages exchanged
- Error rate < 10%

### 4. Stress Test (`stress-test.js`)

Pushes the system beyond normal load to find breaking points.

```bash
k6 run stress-test.js
```

**Load Profile:**
- Ramp to 100 VUs (2m)
- Sustain 100 VUs (5m)
- Spike to 200 VUs (2m)
- Sustain 200 VUs (3m)
- Recover to 50 VUs (2m)
- Recovery period (3m)
- Ramp down (2m)

**Total Duration:** ~19 minutes

**Thresholds:**
- P99 response time < 5s
- Error rate < 20% (stress conditions)

## Running Tests

### Run Individual Tests

```bash
# API load test
k6 run api-load-test.js

# Meeting load test
k6 run meeting-load-test.js

# WebSocket load test
k6 run websocket-load-test.js

# Stress test
k6 run stress-test.js
```

### Run All Tests

```bash
npm run test:all
```

### Custom Configuration

Override default URLs:

```bash
API_URL=https://api.production.com/api k6 run api-load-test.js
WS_URL=wss://ws.production.com k6 run websocket-load-test.js
```

### Run with Different Load

Modify stages in the test file or use environment variables:

```bash
K6_VUS=100 K6_DURATION=5m k6 run api-load-test.js
```

## Interpreting Results

### Metrics Explained

**http_req_duration:** Time from request start to response received
- **p(95):** 95% of requests completed within this time
- **p(99):** 99% of requests completed within this time

**http_req_failed:** Percentage of failed HTTP requests

**http_reqs:** Total number of HTTP requests made

**vus:** Number of virtual users (concurrent connections)

**data_received/data_sent:** Network traffic

### Success Criteria

**API Load Test:**
- ✅ P95 < 500ms
- ✅ Error rate < 10%
- ✅ All 50 VUs handle load smoothly

**Meeting Load Test:**
- ✅ P95 < 1000ms
- ✅ Error rate < 5%
- ✅ 50+ concurrent participants in meetings

**WebSocket Test:**
- ✅ 50 concurrent connections
- ✅ 100+ messages exchanged
- ✅ < 1s connection time

**Stress Test:**
- ✅ System handles 100 VUs
- ✅ Degrades gracefully at 200 VUs
- ✅ Recovers after spike

## Output Formats

### Console Output (default)

```bash
k6 run api-load-test.js
```

### JSON Output

```bash
k6 run --out json=results.json api-load-test.js
```

### CSV Output

```bash
k6 run --out csv=results.csv api-load-test.js
```

### Cloud Output (k6 Cloud)

```bash
k6 cloud api-load-test.js
```

### InfluxDB Output

```bash
k6 run --out influxdb=http://localhost:8086/k6 api-load-test.js
```

## Performance Targets

| Metric | Target | Actual |
|--------|--------|--------|
| Response Time (P95) | < 500ms | TBD |
| Response Time (P99) | < 1000ms | TBD |
| Throughput | 1000 req/s | TBD |
| Concurrent Users | 50+ | TBD |
| Error Rate | < 1% | TBD |
| WebSocket Connections | 50+ | TBD |

## Troubleshooting

### High Error Rates

- Check server logs for errors
- Verify database connection pool size
- Ensure sufficient server resources
- Check rate limiting configuration

### Slow Response Times

- Monitor database query performance
- Check network latency
- Review server CPU/memory usage
- Optimize database indexes

### WebSocket Issues

- Verify WebSocket server is running
- Check firewall/proxy settings
- Monitor connection pool limits
- Review WebSocket timeout settings

## Best Practices

1. **Baseline First:** Run tests against development environment first
2. **Gradual Increase:** Start with small load and increase gradually
3. **Monitor Resources:** Watch CPU, memory, database during tests
4. **Multiple Runs:** Run tests multiple times for consistency
5. **Production-like Data:** Use realistic data volumes
6. **Clean Up:** Clear test data between runs

## Next Steps

After load testing:

1. Analyze results and identify bottlenecks
2. Optimize slow endpoints
3. Increase database connection pool if needed
4. Add caching for frequently accessed data
5. Consider horizontal scaling for high load
6. Set up monitoring and alerting
7. Schedule regular performance tests

## References

- [k6 Documentation](https://k6.io/docs/)
- [k6 Examples](https://k6.io/docs/examples/)
- [Performance Testing Guide](https://k6.io/docs/testing-guides/performance-testing/)
