package com.venafi;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet("/CertificateInfoServlet")
public class CertificateInfoServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Set the response content type
        response.setContentType("text/html;charset=UTF-8");

        // Get certificate file path from the X-Certpath header
        String certFilePath = request.getHeader("X-Certpath");
        
        // Create a PrintWriter to write the response
        PrintWriter out = response.getWriter();
        
        try {
            if (certFilePath == null || certFilePath.isEmpty()) {
                throw new Exception("Certificate file path is empty or missing in the X-Certpath header.");
            }
            
            // Load and parse the certificate
            CertificateFactory cf = CertificateFactory.getInstance("X.509");
            FileInputStream fis = new FileInputStream(certFilePath);
            X509Certificate cert = (X509Certificate) cf.generateCertificate(fis);
            
            // Extract information from the certificate
            String serialNumber = cert.getSerialNumber().toString();
            String subjectDN = cert.getSubjectDN().getName();
            String issuerDN = cert.getIssuerDN().getName();
            Date validFrom = cert.getNotBefore();
            Date validTo = cert.getNotAfter();
            String sigAlgName = cert.getSigAlgName();
            int keySize = cert.getPublicKey().getEncoded().length * 8;

            // Write the certificate info to the response
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head><title>Certificate Information</title></head>");
            out.println("<body>");
            out.println("<h1>Certificate Information</h1>");
            out.println("<p>Certificate File: " + certFilePath + "</p>");
            out.println("<table border='1' cellpadding='10'>");
            out.println("<tr><th>Field</th><th>Value</th></tr>");
            out.println("<tr><td>Serial Number</td><td>" + serialNumber + "</td></tr>");
            out.println("<tr><td>Subject DN</td><td>" + subjectDN + "</td></tr>");
            out.println("<tr><td>Issuer DN</td><td>" + issuerDN + "</td></tr>");
            out.println("<tr><td>Valid From</td><td>" + new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(validFrom) + "</td></tr>");
            out.println("<tr><td>Valid To</td><td>" + new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(validTo) + "</td></tr>");
            out.println("<tr><td>Signature Algorithm</td><td>" + sigAlgName + "</td></tr>");
            out.println("<tr><td>Key Size</td><td>" + keySize + " bits</td></tr>");
            out.println("</table>");
            out.println("</body>");
            out.println("</html>");

            fis.close();

        } catch (Exception e) {
            // Handle any exceptions and print an error message
            out.println("<h3>Error: " + e.getMessage() + "</h3>");
        } finally {
            out.close();
        }
    }
}
