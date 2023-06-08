using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.Models
{
    public class ReporteModel
    {
        public byte[] RenderedBytes { get; }

        public string MimeType { get; }

        public string Encoding { get; }

        public string FileNameExtension { get; }

        public ReporteModel(byte[] renderedBytes, string mimeType, string encoding, string fileNameExtension)
        {
            RenderedBytes = renderedBytes;
            MimeType = mimeType;
            Encoding = encoding;
            FileNameExtension = fileNameExtension;
        }
    }
}