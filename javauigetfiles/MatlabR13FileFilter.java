import java.io.File; 
import java.util.*; 
import javax.swing.*;
import javax.swing.filechooser.*;

public class MatlabR13FileFilter extends FileFilter{
	
	private String description;
	private String selector1,selector2;
	
	//Constructor
	public MatlabR13FileFilter(String selector,String description){
		if(selector == null){
			throw new NullPointerException("La description (ou selector) ne peut être null.");	
		}
		selector=selector.toLowerCase();
		int star = selector.indexOf("*");
		if (selector.regionMatches(0, "*.*", 0, 3))
		{
			this.selector1 = "";
			this.selector2 = "";
		}
		else 
		{
			if(selector.lastIndexOf("*") != star){
				throw new IllegalArgumentException("Selector cannot contain more than one generic character '*'.");	
			}
			if (star>=0)
			{	
				this.selector1 = selector.substring(0,star);
				this.selector2 = selector.substring(star+1);
			}
			else
			{
				this.selector1 = selector;
				this.selector2 = selector;
			}
		}		
		this.description = description;
	}
	
	public MatlabR13FileFilter(String selector){
		this(selector,"(" + selector + ")");		
		}
	
	
	// FileFilter methods
	public boolean accept(File file){
		if(file.isDirectory()) { 
			return true; 
		} 
		String filename = file.getName().toLowerCase(); 		
		return filename.startsWith(selector1) && filename.endsWith(selector2);					
	}
	public String getDescription(){
		return description;
	}
}