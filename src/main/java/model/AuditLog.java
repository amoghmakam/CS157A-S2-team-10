package model;
import java.sql.Timestamp;

public class AuditLog {
    private int auditID;
    private int userID;
    private String actionType;
    private String actionDescription;
    private Timestamp actionTime;

    public AuditLog(int auditID, int userID, String actionType, String actionDescription, Timestamp actionTime){
        this.auditID = auditID;
        this.userID = userID;
        this.actionType = actionType;
        this.actionDescription = actionDescription;
        this.actionTime = actionTime;
    }

    public int getAuditID() {
        return auditID;
    }

    public void setAuditID(int auditID) {
        this.auditID = auditID;
    }

    public int getUserID() {
        return userID;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }

    public String getActionType() {
        return actionType;
    }

    public void setActionType(String actionType) {
        this.actionType = actionType;
    }

    public String getActionDescription() {
        return actionDescription;
    }

    public void setActionDescription(String actionDescription) {
        this.actionDescription = actionDescription;
    }

    public Timestamp getActionTime() {
        return actionTime;
    }

    public void setActionTime(Timestamp actionTime) {
        this.actionTime = actionTime;
    }
}

