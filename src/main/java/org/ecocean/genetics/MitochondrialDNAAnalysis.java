package org.ecocean.genetics;

import java.io.IOException;
import java.util.Properties;

import org.ecocean.CommonConfiguration;

public class MitochondrialDNAAnalysis extends GeneticAnalysis{


  private static final long serialVersionUID = -677491893195428942L;
  private static String type="MitochondrialDNA";
  private String haplotype;
  private static Properties haploColorProps = new Properties();
  
  //Empty constructor required for JDO.
  //DO NOT USE
  public MitochondrialDNAAnalysis() {}
  
  public MitochondrialDNAAnalysis(String analysisID, String haplotype, String correspondingEncounterNumber, String sampleID) {
    super(analysisID, type, correspondingEncounterNumber, sampleID);
    this.haplotype=haplotype;
  }
  
  public String getHaplotype(){return haplotype.trim();}
  public void setHaplotype(String newHaplo){this.haplotype=newHaplo;};
  
  public String getColorCode(String haplotype){
    initializeColorCodes();
    return haploColorProps.getProperty(haplotype);
   }



  private static void initializeColorCodes() {
    //set up the file input stream
    if (haploColorProps.size() == 0) {
      try {
        haploColorProps.load(CommonConfiguration.class.getResourceAsStream("/bundles/haplotypeColorCodes.properties"));
      } catch (IOException ioe) {
        ioe.printStackTrace();
      }
    }
  }
  
  public String getHTMLString(){
    String paramValues=super.getHTMLString();
    if((this.getHaplotype()!=null)&&(!this.getHaplotype().equals(""))){paramValues+="     Haplotype: "+this.getHaplotype()+"<br />";}
  return paramValues; 
  }
  
  
}
