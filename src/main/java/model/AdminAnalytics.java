package model;

import java.util.List;

public class AdminAnalytics {
    private int totalServices;
    private int openServices;
    private int totalUsers;
    private int activeCheckIns;
    private int totalCompletedVisits;
    private double averageVisitMinutes;
    private int flaggedRecords;

    private List<ServiceAnalyticsRow> busiestServices;
    private List<HourlyVolumeRow> hourlyVolume;

    public int getTotalServices() { return totalServices; }
    public void setTotalServices(int totalServices) { this.totalServices = totalServices; }

    public int getOpenServices() { return openServices; }
    public void setOpenServices(int openServices) { this.openServices = openServices; }

    public int getTotalUsers() { return totalUsers; }
    public void setTotalUsers(int totalUsers) { this.totalUsers = totalUsers; }

    public int getActiveCheckIns() { return activeCheckIns; }
    public void setActiveCheckIns(int activeCheckIns) { this.activeCheckIns = activeCheckIns; }

    public int getTotalCompletedVisits() { return totalCompletedVisits; }
    public void setTotalCompletedVisits(int totalCompletedVisits) { this.totalCompletedVisits = totalCompletedVisits; }

    public double getAverageVisitMinutes() { return averageVisitMinutes; }
    public void setAverageVisitMinutes(double averageVisitMinutes) { this.averageVisitMinutes = averageVisitMinutes; }

    public int getFlaggedRecords() { return flaggedRecords; }
    public void setFlaggedRecords(int flaggedRecords) { this.flaggedRecords = flaggedRecords; }

    public List<ServiceAnalyticsRow> getBusiestServices() { return busiestServices; }
    public void setBusiestServices(List<ServiceAnalyticsRow> busiestServices) { this.busiestServices = busiestServices; }

    public List<HourlyVolumeRow> getHourlyVolume() { return hourlyVolume; }
    public void setHourlyVolume(List<HourlyVolumeRow> hourlyVolume) { this.hourlyVolume = hourlyVolume; }
}