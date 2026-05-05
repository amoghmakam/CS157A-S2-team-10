package model;

public class HourlyVolumeRow {
    private int hour;
    private int checkIns;
    private int checkOuts;

    public int getHour() { return hour; }
    public void setHour(int hour) { this.hour = hour; }

    public int getCheckIns() { return checkIns; }
    public void setCheckIns(int checkIns) { this.checkIns = checkIns; }

    public int getCheckOuts() { return checkOuts; }
    public void setCheckOuts(int checkOuts) { this.checkOuts = checkOuts; }
}