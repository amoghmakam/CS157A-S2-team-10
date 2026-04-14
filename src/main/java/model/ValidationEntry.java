package model;

public class ValidationEntry {
    private int validationId;
    private int checkInId;
    private int staffId;
    private String validationType;
    private String validationReason;
    private String validationTime;

    public ValidationEntry() {
    }

    public int getValidationId() {
        return validationId;
    }

    public void setValidationId(int validationId) {
        this.validationId = validationId;
    }

    public int getCheckInId() {
        return checkInId;
    }

    public void setCheckInId(int checkInId) {
        this.checkInId = checkInId;
    }

    public int getStaffId() {
        return staffId;
    }

    public void setStaffId(int staffId) {
        this.staffId = staffId;
    }

    public String getValidationType() {
        return validationType;
    }

    public void setValidationType(String validationType) {
        this.validationType = validationType;
    }

    public String getValidationReason() {
        return validationReason;
    }

    public void setValidationReason(String validationReason) {
        this.validationReason = validationReason;
    }

    public String getValidationTime() {
        return validationTime;
    }

    public void setValidationTime(String validationTime) {
        this.validationTime = validationTime;
    }
}