using Data.Procedures;
using Data.Tables;
using Domain.Helpers;
using Domain.Services;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Entities
{
    public class CategoriaPago : ICategoriaPago
    {
        public int? CategoriaId { get; set; }
        public string Descripcion { get; set; }
        public int Prioridad { get; set; }
        public int Nivel { get; set; }
        public string NivelDesc { get; set; }
        public int TipoAlumno { get; set; }
        public string TipoAlumnoDesc { get; set; }
        public bool EsObligacion { get; set; }
        public string CodBcoComercio { get; set; }
        public List<int> CuentasDeposito { get; set; }
        public List<CuentaDepoEntidad> CuentasDepositoEntidad { get; set; }
        public bool Habilitado { get; set; }


        private readonly TC_CategoriaPago _categoriaPago;
        private readonly TI_ConceptoCategoriaPago _conceptoCategoriaPago;

        public CategoriaPago()
        {
            _categoriaPago = new TC_CategoriaPago();
            _conceptoCategoriaPago = new TI_ConceptoCategoriaPago();
        }

        public CategoriaPago(TC_CategoriaPago table)
        {
            this.CategoriaId = table.I_CatPagoID;
            this.Descripcion = table.T_CatPagoDesc;
            this.Nivel = table.I_Nivel;
            this.Prioridad = table.I_Prioridad;
            this.TipoAlumno = table.I_TipoAlumno;
            this.EsObligacion = table.B_Obligacion;
            this.CodBcoComercio = table.N_CodBanco;
            this.Habilitado = table.B_Habilitado;
        }

        public Response ChangeState(int categoriaPagoId, bool currentState, int currentUserId)
        {
            _categoriaPago.I_CatPagoID = categoriaPagoId;
            _categoriaPago.B_Habilitado = !currentState;
            _categoriaPago.D_FecMod = DateTime.Now;

            return new Response(_categoriaPago.ChangeState(currentUserId));
        }

        public List<CategoriaPago> Find()
        {
            var result = new List<CategoriaPago>();
            var nivel = TC_CatalogoOpcion.FindByParametro((int)Parametro.Grado);
            var tipoAlumno = TC_CatalogoOpcion.FindByParametro((int)Parametro.TipoAlumno);

            foreach (var item in TC_CategoriaPago.FindAll())
            {
                result.Add(new CategoriaPago(item)
                {
                    NivelDesc = nivel.Find(x => x.I_OpcionID == item.I_Nivel).T_OpcionDesc,
                    TipoAlumnoDesc = tipoAlumno.Find(x => x.I_OpcionID == item.I_TipoAlumno).T_OpcionDesc
                });
            }

            return result;
        }

        public CategoriaPago Find(int categoriaPagoId)
        {
            var cuentas = USP_S_CuentaDeposito_Habilitadas.Execute(categoriaPagoId);

            return new CategoriaPago(TC_CategoriaPago.FindByID(categoriaPagoId))
            {
                CuentasDeposito = cuentas != null ? cuentas.Select(x => x.I_CtaDepositoID).ToList(): new List<int>(),
                CuentasDepositoEntidad = cuentas != null ? cuentas.Select(x => new CuentaDepoEntidad()
                {
                    CuentaDepoId = x.I_CtaDepositoID,
                    EntidadFinanId = x.I_EntidadFinanID
                }).ToList() : new List<CuentaDepoEntidad>()
            };
        }

        public Response Save(CategoriaPago categoriaPago, int currentUserId, SaveOption saveOption)
        {
            _categoriaPago.I_CatPagoID = categoriaPago.CategoriaId;
            _categoriaPago.T_CatPagoDesc = categoriaPago.Descripcion;
            _categoriaPago.I_Prioridad = categoriaPago.Prioridad;
            _categoriaPago.I_TipoAlumno = categoriaPago.TipoAlumno;
            _categoriaPago.I_Nivel = categoriaPago.Nivel;
            _categoriaPago.B_Obligacion = categoriaPago.EsObligacion;
            _categoriaPago.N_CodBanco = categoriaPago.CodBcoComercio;

            DataTable dataTable = new DataTable();
            dataTable.Columns.Add("C_ID");
            dataTable.Columns.Add("B_Habilitado");

            foreach (var item in categoriaPago.CuentasDeposito)
            {
                dataTable.Rows.Add(item, true);
            }

            switch (saveOption)
            {
                case SaveOption.Insert:
                    _categoriaPago.D_FecCre = DateTime.Now;
                    return new Response(_categoriaPago.Insert(currentUserId, dataTable));

                case SaveOption.Update:
                    _categoriaPago.D_FecMod = DateTime.Now;
                    return new Response(_categoriaPago.Update(currentUserId, dataTable));
            }

            return new Response()
            {
                Value = false,
                Message = "Operación Inváiida."
            };
        }

        public Response ConceptosSave(int categoriaId, List<int> conceptosId)
        {
            DataTable dataTable = new DataTable();
            dataTable.Columns.Add("C_ID");
            dataTable.Columns.Add("B_Habilitado");

            _conceptoCategoriaPago.I_CatPagoID = categoriaId;
            foreach (var conceptoId in conceptosId)
            {
                dataTable.Rows.Add(conceptoId, true);
            }

            var result = new Response(_conceptoCategoriaPago.Save(dataTable));

            return result;
        }

        public List<ConceptoEntity> GetConceptos(int categoriaId)
        {
            List<ConceptoEntity> conceptoEntities = new List<ConceptoEntity>();

            foreach (var item in _conceptoCategoriaPago.FindByCategoriaID(categoriaId))
            {
                conceptoEntities.Add(new ConceptoEntity()
                {
                    I_ConceptoID = item.I_ConceptoID.Value,
                    T_ConceptoDesc = item.T_ConceptoDesc,
                    T_Clasificador = item.T_Clasificador,
                    I_Monto = item.I_Monto,
                    I_MontoMinimo = item.I_MontoMinimo
                });
            }

            return conceptoEntities;
        }
    }
}
