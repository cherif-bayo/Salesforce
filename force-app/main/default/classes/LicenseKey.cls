/**
 * Created by LBEA on 06/10/2020.
 */

public with sharing class LicenseKey {
    public String keyNumber;
    public String id;
    public String productId;
    public List<String> products; // 1 solution avec éventuellement des options
    public Integer nbActivations;
    public Integer validity; // Durée de vie en secondes
    public CryptlexMetaData metadata; // Voir doc dans teams
    public String policy;
    public Boolean IsInactive;
    public Date ExpirationDate;
    public String Expiration;
    public Date StartDate;
    public Integer Quantity;
    public Integer QuantityBought;
    public Integer QuantityActivated;
    public Boolean allowVmActivation = true;
    public Integer allowedFloatingClients;
}