package model;

public class ServiceAnalyticsRow {
    private String serviceName;
    private int totalVisits;
    private int activeVisits;
    private double averageDuration;

    public String getServiceName() { return serviceName; }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }

    public int getTotalVisits() { return totalVisits; }
    public void setTotalVisits(int totalVisits) { this.totalVisits = totalVisits; }

    public int getActiveVisits() { return activeVisits; }
    public void setActiveVisits(int activeVisits) { this.activeVisits = activeVisits; }

    public double getAverageDuration() { return averageDuration; }
    public void setAverageDuration(double averageDuration) { this.averageDuration = averageDuration; }
}