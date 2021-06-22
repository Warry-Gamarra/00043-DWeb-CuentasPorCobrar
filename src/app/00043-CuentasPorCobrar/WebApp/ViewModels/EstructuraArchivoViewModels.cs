using Domain.Entities;
using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class ArchivoIntercambioViewModel
    {
        public int ArchivoIntercambioID { get; set; }
        public string TipoArchivo { get; set; }
        public string EntiFinan { get; set; }
        public int CantSecciones { get; set; }
        public int CantColumns { get; set; }
        public bool? Habilitado { get; set; }

        public ArchivoIntercambioViewModel() { }
        public ArchivoIntercambioViewModel(ArchivoIntercambio model)
        {
            this.ArchivoIntercambioID = model.TipArchivoEntFinanID.Value;
            this.EntiFinan = model.EntidadFinan;
            this.TipoArchivo = model.TipoArchivo;
            this.Habilitado = model.Habilitado;
        }
    }


    public class RegistrarArchivoIntercambioViewModel
    {
        public int EstructArchivoID { get; set; }

        [Required]
        [Display(Name = "Entidad Recaudadora")]
        public int EntiFinanId { get; set; }
        public string EntiFinanNom { get; set; }

        [Required]
        [Display(Name = "Tipo de archivo")]
        public TipoArchivoEntFinan TipoArchivo { get; set; }

        public IList<SeccionArchivoViewModel> SeccionesArchivo { get; set; }
    }


    public class SeccionArchivoViewModel
    {
        public int SecArchivoID { get; set; }

        [Display(Name = "Nombre de la sección:")]
        public string SecArchivoDesc { get; set; }
        [Display(Name = "Tipo de sección:")]
        public TipoSeccionArchivo TipoSeccion { get; set; }

        [Display(Name = "Fila inicio:")]
        public int FilPosicionIni { get; set; }

        [Display(Name = "Fila fin:")]
        public int FilPosicionFin { get; set; }

        [Display(Name = "Longitud:")]
        public int Longitud
        {
            get
            {
                int length = (this.FilPosicionFin - this.FilPosicionIni < 0) ? 0 : this.FilPosicionFin - this.FilPosicionIni + 1;
                return length;
            }
        }

        public int EstructArchivoID { get; set; }
        public TipoArchivoEntFinan TipoArchivoEnt { get; set; }
        public IList<ColumnaSeccionViewModel> ColumnasSeccion { get; set; }
    }


    public class ColumnaSeccionViewModel
    {
        public int SeccionArchivo { get; set; }
        public int ColumnSecID { get; set; }

        [Display(Name = "Nombre de la campo:")]
        public string ColSecDesc { get; set; }

        [Display(Name = "Columna inicio:")]
        public int ColPosicionIni { get; set; }

        [Display(Name = "Columna Final:")]
        public int ColPosicionFin { get; set; }

        [Display(Name = "Campo de tabla:")]
        public int? CampoTablaId { get; set; }

        public string CampoTablaDesc { get; set; }
        public string CampoTablaNom { get; set; }
        public string TablaCampoNom { get; set; }

        [Display(Name = "Longitud:")]
        public int Longitud
        {
            get
            {
                int length = (this.ColPosicionFin - this.ColPosicionIni< 0) ? 0 : this.ColPosicionFin - this.ColPosicionIni+ 1;
                return length;
            }
        }

    }


    public class CamposTablaViewModel
    {
        public int? CampoId { get; set; }

        [Required]
        [Display(Name = "Descripción")]
        public string DescCampo { get; set; }

        [Required]
        [Display(Name = "Tabla")]
        public string NombreTabla { get; set; }

        [Required]
        [Display(Name = "Columna")]
        public string NombreCampoTabla { get; set; }

        [Required]
        [Display(Name = "Tipo de archivo")]
        public TipoArchivoEntFinan TipoArchivo { get; set; }

        public string TipoArchivoDesc { get; set; }

        public bool? Habilitado { get; set; }

        public CamposTablaViewModel() { }

        public CamposTablaViewModel(CampoTablaPago campoTablaPago)
        {
            this.CampoId = campoTablaPago.CampoId;
            this.DescCampo = campoTablaPago.DescCampo;
            this.NombreCampoTabla = campoTablaPago.NombreCampoTabla;
            this.NombreTabla = campoTablaPago.NombreTabla;
            this.TipoArchivo = (TipoArchivoEntFinan)campoTablaPago.TipoArchivo;
            this.TipoArchivoDesc = TipoArchivo.ToString().Replace('_', ' ');
            this.Habilitado = campoTablaPago.Habilitado;
        }
    }

}

