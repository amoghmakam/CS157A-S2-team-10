package model;

public class WaitTrend {
    private String label;
    private double avgWait;
    private int totalCheckIns;
    private String crowdLevel;

    public WaitTrend() {
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public double getAvgWait() {
        return avgWait;
    }

    public void setAvgWait(double avgWait) {
        this.avgWait = avgWait;
    }

    public int getTotalCheckIns() {
        return totalCheckIns;
    }

    public void setTotalCheckIns(int totalCheckIns) {
        this.totalCheckIns = totalCheckIns;
    }

    public String getCrowdLevel() {
        return crowdLevel;
    }

    public void setCrowdLevel(String crowdLevel) {
        this.crowdLevel = crowdLevel;
    }
}