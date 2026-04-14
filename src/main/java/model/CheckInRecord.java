package model;

import java.sql.Timestamp;

public class CheckInRecord {
    private int checkInId;
    private int studentId;
    private String serviceName;
    private Timestamp checkInTime;
    private Timestamp checkOutTime;
    private Integer crowdEstimate;
    private Integer duration;

    public CheckInRecord() {
    }

    public int getCheckInId() {
        return checkInId;
    }

    public void setCheckInId(int checkInId) {
        this.checkInId = checkInId;
    }

    public int getStudentId() {
        return studentId;
    }

    public void setStudentId(int studentId) {
        this.studentId = studentId;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public Timestamp getCheckInTime() {
        return checkInTime;
    }

    public void setCheckInTime(Timestamp checkInTime) {
        this.checkInTime = checkInTime;
    }

    public Timestamp getCheckOutTime() {
        return checkOutTime;
    }

    public void setCheckOutTime(Timestamp checkOutTime) {
        this.checkOutTime = checkOutTime;
    }

    public Integer getCrowdEstimate() {
        return crowdEstimate;
    }

    public void setCrowdEstimate(Integer crowdEstimate) {
        this.crowdEstimate = crowdEstimate;
    }

    public Integer getDuration() {
        return duration;
    }

    public void setDuration(Integer duration) {
        this.duration = duration;
    }
}