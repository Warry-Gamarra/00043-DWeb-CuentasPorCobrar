using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebApp.ViewModels
{
    public class ObligacionViewModel
    {
        public int Id { get; set; }
        public string Descripcion { get; set; }
        public bool Fraccionable { get; set; }
        public bool Concepto_General { get; set; }
        public bool Agrupa_Conceptos { get; set; }
        public int Tipo_Alumno { get; set; }
        public int Nivel_Alumno { get; set; }
        public int Tipo_Oblicacion { get; set; }
        public int Cuota_Pago { get; set; }
        public string Clasificador { get; set; }
        public string Clasificador_Cinco_Digitos { get; set; }
        public bool Calculado { get; set; }
        public int Calculado_Opcion { get; set; }
        public bool Anio_Periodo { get; set; }
        public int Anio { get; set; }
        public int Periodo { get; set; }
        public bool Especialidad { get; set; }
        public int Especialidad_Opcion { get; set; }
        public bool Grupo_Cod_Rc { get; set; }
        public int Grupo_Cod_Rc_Opcion { get; set; }
        public bool Codigo_Ingreso { get; set; }
        public int Codigo_Ingreso_Opcion { get; set; }
        public bool Concepto_Agrupa { get; set; }
        public int Concepto_Agrupa_Opcion { get; set; }
        public bool Concepto_Afecta { get; set; }
        public bool Concepto_Afecta_Opcion { get; set; }
        public int Nro_Pagos { get; set; }
        public bool Porcentaje { get; set; }
        public float Monto { get; set; }
        public float Monto_Minimo { get; set; }
        public string Descripcion_Larga { get; set; }
        public string Observacion { get; set; }

        //public IEnumerable<PeriodoAcademico> Lista_Periodos_Academicos { get; set; }
        //public IEnumerable<Periodo> Lista_Periodos { get; set; }
        //public IEnumerable<Especialidad> Lista_Especialidades { get; set; }
        //public IEnumerable<Dependencia> Lista_Dependencias { get; set; }
        //public IEnumerable<GrupoCodRc> Lista_Grupo_Cod_Rc { get; set; }
        //public IEnumerable<CodigoIngreso> Lista_Codigo_Ingreso { get; set; }
        //public IEnumerable<ConceptoAgrupa> Lista_Concepto_Agrupa { get; set; }
        //public IEnumerable<ConceptoAfecta> Lista_Concepto_Afecta { get; set; }
    }
}