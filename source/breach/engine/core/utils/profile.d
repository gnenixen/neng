module engine.core.utils.profile;

import engine.core.log;
import engine.core.os;

struct SExecutionTimeProfiler {
private:
    long lstartTime = 0;
    long lendTime = 0;

public:
    void start() { lstartTime = OS.time_get(); }
    void stop() { lendTime = OS.time_get(); }

    float getExecutionTimeInSeconds() {
        return (lendTime - lstartTime) / 1_000_000_000.0f;
    }
}
