/**
 * Created by LBEA on 06/10/2020.
 */

public with sharing class CryptlexMetaData {
    public Integer domain; // Domaine de la licence
    public Long access; // Acces permis par la licence (bitset solutions + options)
    public Integer scope; // Par utilisateur(valeur 0) / par machine(valeur 1)
    public Date endUp; // Date fin mise à jour des perpetuelles
    public String productId; // L'id de produit cryptlex <> pour Xlstat, Xlsrisk...
}