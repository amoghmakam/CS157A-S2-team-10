package model;

public class ValidationEntry {
    private int validationId;
    private int checkInId;
    private int staffId;
    private String validationType;
    private String validationReason;
    private String validationTime;
    private String serviceName;
    private String studentName;
    private String staffName;

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

    public String getServiceName() { return serviceName; }
    public void setServiceName(String serviceName) { this.serviceName = serviceName; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getStaffName() { return staffName; }
    public void setStaffName(String staffName) { this.staffName = staffName; }
}