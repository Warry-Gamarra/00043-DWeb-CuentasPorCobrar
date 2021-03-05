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
    public class Dependencia : IDependencia
    {
        private readonly TC_DependenciaUNFV _dependenciaRepository;

        public int? Id { get; set; }
        public string Codigo { get; set; }
        public string CodigoPl { get; set; }
        public string Abreviatura { get; set; }
        public string Descripcion { get; set; }
        public bool EsAcademico { get; set; }
        public bool Habilitado { get; set; }

        public Dependencia()
        {
            _dependenciaRepository = new TC_DependenciaUNFV();
        }

        public Dependencia(TC_DependenciaUNFV tablaDependencia)
        {
            this.Id = tablaDependencia.I_DependenciaID;
            this.Codigo = tablaDependencia.C_DepCod;
            this.CodigoPl = tablaDependencia.C_DepCodPl;
            this.Descripcion = tablaDependencia.T_DepDesc;
            this.Habilitado = tablaDependencia.B_Habilitado;
        }


        public Response ChangeState(int dependenciaId, bool currentState, int currentUserId)
        {
            _dependenciaRepository.I_DependenciaID = dependenciaId;
            _dependenciaRepository.D_FecMod = DateTime.Now;
            _dependenciaRepository.B_Habilitado = !currentState;

            return new Response(_dependenciaRepository.ChangeState(currentUserId));
        }

        public List<Dependencia> Find()
        {
            var result = new List<Dependencia>();

            foreach (var item in _dependenciaRepository.Find())
            {
                result.Add(new Dependencia(item));
            }
            return result;
        }

        public Dependencia Find(int dependenciaId)
        {
            var data = _dependenciaRepository.Find(dependenciaId);

            return new Dependencia(data);
        }


        public Response Save(Dependencia dependencia, int currentUserId, SaveOption saveOption)
        {
            _dependenciaRepository.I_DependenciaID = dependencia.Id;
            _dependenciaRepository.T_DepDesc = dependencia.Descripcion.ToUpper();
            _dependenciaRepository.C_DepCod = dependencia.Codigo.ToUpper();
            _dependenciaRepository.C_DepCodPl = string.IsNullOrEmpty(dependencia.CodigoPl) ? dependencia.CodigoPl : dependencia.CodigoPl.ToUpper();
            _dependenciaRepository.T_DepAbrev = string.IsNullOrEmpty(dependencia.Abreviatura) ? dependencia.Abreviatura : dependencia.Abreviatura.ToUpper();

            switch (saveOption)
            {
                case SaveOption.Insert:
                    _dependenciaRepository.D_FecCre = DateTime.Now;
                    return new Response(_dependenciaRepository.Insert(currentUserId));

                case SaveOption.Update:
                    _dependenciaRepository.D_FecMod = DateTime.Now;
                    return new Response(_dependenciaRepository.Update(currentUserId));
            }

            return new Response()
            {
                Value = false,
                Message = "Operación Inváiida."
            };
        }
    }
}
