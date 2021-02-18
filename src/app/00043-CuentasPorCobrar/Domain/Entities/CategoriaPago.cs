using Data.Tables;
using Domain.DTO;
using Domain.Services;
using System;
using System.Collections.Generic;
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
        public bool Habilitado { get; set; }


        private readonly TC_CategoriaPago _categoriaPago;

        public CategoriaPago()
        {
            _categoriaPago = new TC_CategoriaPago();
        }

        public CategoriaPago(TC_CategoriaPago table)
        {
            this.CategoriaId = table.I_CatPagoID;
            this.Descripcion = table.T_CatPagoDesc;
            this.Nivel = table.I_Nivel;
            this.Prioridad = table.I_Prioridad;
            this.TipoAlumno = table.I_TipoAlumno;
            this.EsObligacion = table.B_Obligacion;
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
            return new CategoriaPago(TC_CategoriaPago.FindByID(categoriaPagoId));
        }

        public Response Save(CategoriaPago categoriaPago, int currentUserId, SaveOption saveOption)
        {
            _categoriaPago.I_CatPagoID = categoriaPago.CategoriaId;
            _categoriaPago.T_CatPagoDesc = categoriaPago.Descripcion;
            _categoriaPago.I_Prioridad = categoriaPago.Prioridad;
            _categoriaPago.I_TipoAlumno = categoriaPago.TipoAlumno;
            _categoriaPago.I_Nivel = categoriaPago.Nivel;
            _categoriaPago.B_Obligacion = categoriaPago.EsObligacion;

            switch (saveOption)
            {
                case SaveOption.Insert:
                    _categoriaPago.D_FecCre = DateTime.Now;
                    return new Response(_categoriaPago.Insert(currentUserId));

                case SaveOption.Update:
                    _categoriaPago.D_FecMod = DateTime.Now;
                    return new Response(_categoriaPago.Update(currentUserId));
            }

            return new Response()
            {
                Value = false,
                Message = "Operación Inváiida."
            };
        }
    }
}
